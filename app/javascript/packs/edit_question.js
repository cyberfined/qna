document.addEventListener("turbolinks:load", () => {
    const editButton = document.querySelector("#edit-question-button");
    if(editButton === null)
        return;

    editButton.addEventListener("click", editQuestionButtonHandler);
});

function editQuestionButtonHandler() {
    document.querySelector("#edit-question-form").classList.remove("hide");
    this.classList.add("hide");
}
