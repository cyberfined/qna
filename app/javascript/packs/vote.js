document.addEventListener("turbolinks:load", () => {
    Array.from(document.querySelectorAll(".vote-form")).forEach((voteForm) => {
        setupVoteFormHandler(voteForm);
    });
});

export function setupVoteFormHandler(voteForm) {
    const voteFor = voteForm.querySelector(".vote-for");
    if(voteFor === null)
        return;
    const rating = voteForm.querySelector(".rating");
    const voteAgainst = voteForm.querySelector(".vote-against");
    voteForm.addEventListener("ajax:success", (e) => voteFormHandler(e, rating, voteFor, voteAgainst));
}

function voteFormHandler(e, rating, voteFor, voteAgainst) {
    const result = e.detail[0];
    rating.innerHTML = result.rating;

    if(e.srcElement.classList.contains("vote-for")) {
        if(!voteAgainst.hasAttribute("disabled"))
            voteFor.setAttribute("disabled", "true");
        voteAgainst.removeAttribute("disabled");
    } else {
        if(!voteFor.hasAttribute("disabled"))
            voteAgainst.setAttribute("disabled", "true");
        voteFor.removeAttribute("disabled");
    }
}
