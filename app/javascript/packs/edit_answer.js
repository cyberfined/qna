export function editAnswerButtonHandler(btn) {
    const answerId = btn.dataset.id;
    document.querySelector(`.edit-answer-form[data-id='${answerId}']`).classList.remove("hide");
    btn.classList.add("hide");
}
