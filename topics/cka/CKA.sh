#!/usr/bin/env bash

#switch for opening a browser with: --new-window
browser=/usr/bin/brave-browser

#open current browser with URL provided:
open_browser() {
$browser "$1" &2>1 > /dev/null &
}


cka(){

open_browser https://mail.google.com/mail/u/0/#inbox

open_browser https://calendar.google.com/calendar/u/0/r

#open_browser https://docs.google.com/document/d/1nrsuwQ33N7-84TtLPBnIk1QwZdtamLPU3z2d1vSFlGg/edit?tab=t.0

open_browser https://docs.google.com/document/d/1uYb1bdXIJ7-EmmXJKPbrNJAEzPuhvxM-3qHYPr0iAp4/edit?tab=t.0

open_browser ihttps://www.roboform.com/

open_browser https://www.notion.so/CKA-certification-16ce8a78051080cd8fdde031794df540

open_browser https://www.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/

}

sudo apt update && sudo apt upgrade -y
cka
