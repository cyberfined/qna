// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

const jquery = require("jquery")
global.jQuery = jquery;
require("@nathanvda/cocoon")
require("packs/edit_question")

const editAnswer = require("packs/edit_answer")
global.editAnswerButtonHandler = editAnswer.editAnswerButtonHandler

Rails.start()
Turbolinks.start()
ActiveStorage.start()
