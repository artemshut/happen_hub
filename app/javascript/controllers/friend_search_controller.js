import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "results", "selectedFriends", "hiddenFields"];

  connect() {
    this.members = new Set(); // Track selected members
    this.existingMembers = JSON.parse(this.data.get("existingValues") || "[]");
    this.groupId = this.element.dataset.groupId || null

    // Load existing group members as tags
    this.existingMembers.forEach(member => this.addMemberTag(member.id, member.name, true));
  }

  async search(event) {
    const query = event.target.value.trim();

    if (query.length < 3) {
      this.resultsTarget.innerHTML = "";
      this.resultsTarget.classList.add("hidden");
      return;
    }

    const url = this.groupId ? `/friendships/search?q=${query}&group_id=${this.groupId}` : `/friendships/search?q=${query}`;

    const response = await fetch(url);
    const users = await response.json();

    // Exclude already added group members
    const filteredUsers = users.filter(user => !this.members.has(user.id));

    this.resultsTarget.innerHTML = filteredUsers.map(user => `
      <li class="p-2 hover:bg-gray-200 cursor-pointer"
          data-id="${user.id}"
          data-name="${user.full_name}"
          data-action="click->friend-search#addMember">
        ${user.full_name}
      </li>
    `).join("");

    this.resultsTarget.classList.remove("hidden");
  }

  addMember(event) {
    const id = event.target.dataset.id;
    const name = event.target.dataset.name;
    this.addMemberTag(id, name);
  }

  addMemberTag(id, name, preloaded = false) {
    if (this.members.has(id)) return;
    this.members.add(id);

    const tag = document.createElement("span");
    tag.className = "bg-blue-500 text-white px-3 py-1 rounded-full text-sm flex items-center space-x-2";
    tag.innerHTML = `
      ${name}
      ${!preloaded ? `<button class="ml-2 text-white font-bold" data-id="${id}" data-action="click->friend-search#removeMember">×</button>` : ""}
    `;

    this.selectedFriendsTarget.appendChild(tag);

    if (!preloaded) {
      // Add hidden input field for form submission
      const hiddenInput = document.createElement("input");
      hiddenInput.type = "hidden";
      hiddenInput.name = "group[friend_ids][]"; // Adjusted for GroupMembership
      hiddenInput.value = id;
      this.hiddenFieldsTarget.appendChild(hiddenInput);
    }

    this.resultsTarget.classList.add("hidden");
    this.inputTarget.value = ""; // Reset input
  }

  removeMember(event) {
    const id = event.target.dataset.id;
    this.members.delete(id);
    event.target.parentElement.remove();
    
    // Remove the hidden input
    this.hiddenFieldsTarget.querySelector(`input[value="${id}"]`)?.remove();
  }
}
