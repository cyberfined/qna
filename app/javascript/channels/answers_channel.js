import consumer from "./consumer"

document.addEventListener("turbolinks:load", () => {
    if(gon.question === undefined)
        return;

    const answers = document.querySelector(".answers");

    consumer.subscriptions.create({ channel: "AnswersChannel", id: gon.question.id }, {
      received(answer) {
          if(answer.user_id !== gon.user_id) {
              const ansTempl = require("!!ejs-compiled-loader?{}!./templates/answer.ejs");
              answers.innerHTML += ansTempl({ answer: answer });
              const voteForm = document.querySelector(`.answer[data-id="${answer.id}"] .vote-form`);
              setupVoteFormHandler(voteForm);
          }
      }
    });
});
