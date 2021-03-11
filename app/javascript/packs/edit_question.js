document.addEventListener("DOMContentLoaded", () => {
    editButton = document.querySelector("#edit-button");
    if(editButton === null)
        return;

    editButton.addEventListener("click", showEditForm);
});

function showEditForm() {
    document.querySelector("#edit-form").classList.remove("hide");
    this.classList.add("hide");
}
