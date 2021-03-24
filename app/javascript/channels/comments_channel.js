import consumer from "./consumer"

document.addEventListener("turbolinks:load", () => {
    if(gon.question === undefined)
        return;

    consumer.subscriptions.create({ channel: "CommentsChannel", id: gon.question.id }, {
      received(comment) {
          if(comment.user.id === gon.user_id)
              return;

          const cls = comment.commentable.class;
          const id = comment.commentable.id;
          const comments = document.querySelector(`.comments-${cls}[data-id="${id}"]`); 

          const userSpan = document.createElement("span");
          userSpan.classList.add("comment-user");
          userSpan.innerHTML = comment.user.email + ":";

          const bodySpan = document.createElement("span");
          bodySpan.classList.add("comment-body");
          bodySpan.innerHTML = comment.body;

          const commentDiv = document.createElement("div");
          commentDiv.classList.add("comment");
          commentDiv.appendChild(userSpan);
          commentDiv.appendChild(bodySpan);
          
          comments.appendChild(commentDiv);
      }
    });
});
