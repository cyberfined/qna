module AnswerHelper
  def answer_container(answer, &block)
    cls = answer.best ? 'answer best-answer' : 'answer'
    content_tag :div, data: { id: answer.id }, class: cls do
      block.call
    end
  end

 def mark_answer_best_button(answer)
   cls = answer.best ? 'mark-best-answer-btn hide' : 'mark-best-answer-btn'
   button_to 'Mark best', mark_best_answer_path(answer), remote: true, method: :post, class: cls
 end
end
