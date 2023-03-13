// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import PopUpMsgController from "./pop_up_msg_controller"
application.register("pop-up-msg", PopUpMsgController)

import TimerController from "./timer_controller"
application.register("timer", TimerController)
