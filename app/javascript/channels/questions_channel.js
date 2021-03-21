import consumer from "./consumer"

document.addEventListener("turbolinks:load", () => {
    const questions = document.querySelector("#questions");
    if(questions === null)
        return;

    consumer.subscriptions.create("QuestionsChannel", {
      received(question) {
          const question_link = document.createElement("a");
          question_link.innerHTML = question.title;
          question_link.href = `/questions/${question.id}`;
          const question_tag = document.createElement("p");
          question_tag.appendChild(question_link);
          questions.appendChild(question_tag);
      }
    });
});
