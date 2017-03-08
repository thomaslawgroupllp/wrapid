port module Ports exposing (..)

import Client.PAPortal.Types exposing (Skin, ExtraActivity)
import Client.ExtraPortal.Types exposing (ExtraInfo, Day, UserId, Schedule, ScheduleItem)

port getAllExtraInfo : (String) -> Cmd msg
port receiveAllExtraInfo : (List ExtraActivity -> msg) -> Sub msg

port fetchDailySkin : (String) -> Cmd msg
port receiveDailySkin : (Skin -> msg) -> Sub msg

port addScheduleItem : (UserId, ScheduleItem) -> Cmd msg


port getExtraInfo : ( UserId, Day ) -> Cmd msg
port receiveExtraInfo : (ExtraInfo -> msg) -> Sub msg
