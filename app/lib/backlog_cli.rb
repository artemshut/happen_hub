# frozen_string_literal: true

class BacklogCli
  Task = Struct.new(:status, :id, :title, :notes, keyword_init: true) do
    def in_progress?
      status == "x"
    end

    def todo?
      status == " "
    end

    def slug
      title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
    end

    def render
      lines = []
      lines << "- [#{status}] #{id} #{title}\n"
      notes.each do |note|
        lines << "  #{note.rstrip}\n"
      end
      lines
    end
  end

  Section = Struct.new(:name, :tasks)

  attr_reader :path

  def initialize(path = nil)
    @path = File.expand_path(path || File.join(Dir.pwd, "backlog.md"))
    raise "backlog.md not found at #{path}" unless File.exist?(@path)

    parse!
  end

  def sections
    @sections
  end

  def start_task(task_id)
    ensure_single_in_progress!
    task = delete_task!("Backlog", task_id, expected_status: :todo)
    task.status = "x"
    sections["In Progress"].tasks << task
    save!
    task
  end

  def finish_task(task_id, pr_note: nil)
    task = delete_task!("In Progress", task_id, expected_status: :in_progress)
    task.status = "x"
    task.notes << pr_note if pr_note && !pr_note.empty?
    sections["Done"].tasks.unshift(task)
    save!
    task
  end

  def next_task
    sections.fetch("Backlog").tasks.find(&:todo?)
  end

  def find_task(task_id)
    sections.each_value do |section|
      section.tasks.each do |task|
        return task if task.id == task_id
      end
    end
    nil
  end

  def save!
    File.open(path, "w", encoding: "UTF-8") do |file|
      file.write(@preamble.join)
      @section_order.each_with_index do |section_name, index|
        section = sections.fetch(section_name)
        file.puts "## #{section_name}"
        file.puts
        if section.tasks.empty?
          file.puts "- _empty_"
        else
          section.tasks.each do |task|
            task.render.each { |line| file.write(line) }
          end
        end
        file.puts if index < @section_order.length - 1 || @postamble.any?
      end
      file.write(@postamble.join)
    end
  end

  private

  def parse!
    lines = File.readlines(path, encoding: "UTF-8")
    @preamble = []
    @postamble = []
    @sections = {}
    @section_order = []

    state = :preamble
    current_section = nil
    buffer = []

    lines.each do |line|
      case state
      when :preamble
        if line.start_with?("## ")
          state = :section
          current_section = line.sub(/^## /, "").strip
          @section_order << current_section
          buffer = []
        else
          @preamble << line
        end
      when :section
        if line.start_with?("## ")
          finalize_section(current_section, buffer)
          current_section = line.sub(/^## /, "").strip
          @section_order << current_section
          buffer = []
        elsif line.start_with?("### ")
          finalize_section(current_section, buffer)
          state = :postamble
          @postamble << line
        else
          buffer << line
        end
      when :postamble
        @postamble << line
      end
    end

    finalize_section(current_section, buffer) if state == :section
  end

  def finalize_section(name, lines)
    tasks = []
    i = 0
    while i < lines.length
      line = lines[i]
      if line =~ /^- \[( |x)\] ([A-Z0-9-]+)\s+(.*)$/
        status = Regexp.last_match(1)
        id = Regexp.last_match(2)
        title = Regexp.last_match(3).strip
        notes = []
        i += 1
        while i < lines.length && lines[i].start_with?("  ")
          notes << lines[i].strip
          i += 1
        end
        tasks << Task.new(status: status, id: id, title: title, notes: notes)
      elsif line.start_with?("- _empty_")
        i += 1
      elsif line.strip.empty?
        i += 1
      else
        i += 1
      end
    end

    @sections[name] = Section.new(name, tasks)
  end

  def ensure_single_in_progress!
    return if sections["In Progress"].tasks.empty?

    raise "Only one task can be in progress. Finish the current task first."
  end

  def delete_task!(section_name, task_id, expected_status:)
    section = sections.fetch(section_name)
    index = section.tasks.index { |t| t.id == task_id }
    raise "Task #{task_id} not found in #{section_name}." unless index

    task = section.tasks.delete_at(index)
    case expected_status
    when :todo
      raise "Task #{task_id} is already in progress." unless task.todo?
    when :in_progress
      raise "Task #{task_id} is not marked in progress." unless task.in_progress?
    end
    task
  end
end
