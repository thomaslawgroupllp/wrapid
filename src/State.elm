module State exposing (..)

import Material
import Navigation as Nav
import Types exposing (..)
import Client.ExtraPortal.ExtraPortal as ExtraPortal

import Time exposing (Time, hour)
import Date exposing (Date, fromTime)
import Date.Extra.Compare as CompareDate exposing (Compare2(..))
import Task exposing (perform)


-- import Client.PAPortal.Types as PATypes

import Client.PAPortal.State as PAState


defaultUserID : String
defaultUserID =
    "ciykqvsynnqo60127o3illsce"


init : Nav.Location -> ( Model, Cmd Msg )
init location =
    ( { history = [ location ]
      , currentImg = Nothing
      , currentDate = Nothing
      , currentViewState = Login
      , title = "Yo"
      , mdl = Material.model
      }
    , now
    )

now : Cmd Msg
now =
  Task.perform SetDate Date.now


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
      SetDate newDate ->
        ({model | currentDate = Just newDate}, Cmd.none)
      Tick newTime ->
        let
          newDate = Date.fromTime newTime
        in
          case model.currentDate of
            Just currentDate ->
              if CompareDate.is Same currentDate newDate
              then
                (model, Cmd.none)
              else
                (model, now)
            Nothing ->
              (model, now)
      ChangeView viewState ->
          case viewState of
              LoginView ->
                  ( { model | currentViewState = Login }, Cmd.none )

              ExtraPortalView ->
                  let
                      ( extraPortalModel, epCmd ) =
                          ExtraPortal.initModel defaultUserID model.currentDate model.mdl
                  in
                      ( { model | currentViewState = ExtraPortal extraPortalModel }
                        , Cmd.map (\b -> ChildMsg (ExtraPortalMsg b)) epCmd
                      )

              PAPortalView ->
                let
                  (paModel, paCmd) = PAState.initModel defaultUserID model.currentDate Nothing
                in
                  ( { model | currentViewState = PAPortal paModel }
                  , Cmd.map (\b -> ChildMsg (PAPortalMsg b)) paCmd
                  )


      UrlChange location ->
          ( { model | history = location :: model.history }
          , Cmd.none
          )

      LoginMsg loginMsg ->
          ( model, Cmd.none )

      ChildMsg subMsg->
        case subMsg of
          ExtraPortalMsg epMsg ->
            case model.currentViewState of
              Login -> (model, Cmd.none)
              ExtraPortal curModel ->
                let
                    ( epModel, epCmd ) = ExtraPortal.update epMsg curModel
                in
                    ( { model | currentViewState = ExtraPortal epModel }
                      , Cmd.map (\b -> (ChildMsg (ExtraPortalMsg b))) epCmd )
              PAPortal curModel ->
                (model, Cmd.none)

          PAPortalMsg paMsg ->
              case model.currentViewState of
                Login -> (model, Cmd.none)
                PAPortal curModel ->
                  let
                      ( paPortalModel, paCmd ) = PAState.update paMsg curModel
                  in
                      ( { model | currentViewState = PAPortal paPortalModel }
                        , Cmd.map (\b -> (ChildMsg (PAPortalMsg b))) paCmd )
                ExtraPortal curModel ->
                  (model, Cmd.none)


      ToggleNotifications ->
          ( model, Cmd.none )

      SelectNotification _ ->
          ( model, Cmd.none )

      Mdl message_ ->
          Material.update Mdl message_ model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every hour Tick
        , case model.currentViewState of
            ExtraPortal epModel ->
              Sub.map (\b -> ChildMsg (ExtraPortalMsg b)) (ExtraPortal.subscriptions epModel)
            PAPortal paModel ->
              Sub.map (\b -> ChildMsg (PAPortalMsg b)) (PAState.subscriptions paModel)
            Login ->
              Sub.none
        , Material.subscriptions Mdl model
        ]
