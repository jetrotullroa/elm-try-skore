module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- model


type alias Model =
    { players : List Player
    , name : String
    , playerId : Maybe Int
    , plays : List Play
    }


type alias Player =
    { id : Int
    , name : String
    , points : Int
    }


type alias Play =
    { id : Int
    , playerId : Int
    , name : String
    , points : Int
    }


initModel : Model
initModel =
    { players = []
    , name = ""
    , playerId = Nothing
    , plays = []
    }


type Msg
    = Edit Player
    | Score Player Int
    | Input String
    | Save
    | Cancel
    | DeletePlay Play


update : Msg -> Model -> Model
update msg model =
    case msg of
        Input name ->
            { model | name = name }

        Cancel ->
            { model | name = "", playerId = Nothing }

        Save ->
            if (String.isEmpty model.name) then
                model
            else
                save model

        _ ->
            model


save : Model -> Model
save model =
    case model.playerId of
        Just id ->
            edit model id

        Nothing ->
            add model


edit : Model -> Int -> Model
edit model id =
    let
        newPlayers =
            List.map
                (\player ->
                    if player.id == id then
                        { player | name = model.name }
                    else
                        player
                )
                model.players

        newPlays =
            List.map
                (\play ->
                    if play.playerId == id then
                        { play | name = model.name }
                    else
                        play
                )
                model.plays
    in
        { model
            | players = newPlayers
            , plays = newPlays
            , name = ""
            , playerId = Nothing
        }


add : Model -> Model
add model =
    let
        -- first get the new player details
        player =
            Player (List.length model.players) model.name 0

        -- add the player to the Player list
        newPlayers =
            player :: model.players
    in
        { model
            | players = newPlayers
            , name = ""
        }


view : Model -> Html Msg
view model =
    div [ class "scoreboard" ]
        [ h1 [] [ text "Skore" ]
        , playerSection model
        , playerForm model
        , p [] [ text (toString model) ]
        ]


playerSection : Model -> Html Msg
playerSection model =
    div []
        [ playerListHeader
        , playerList model
        , pointsTotal model
        ]


playerListHeader : Html Msg
playerListHeader =
    header []
        [ div [] [ text "Name" ]
        , div [] [ text "Skore" ]
        ]


playerList : Model -> Html Msg
playerList model =
    ul [] (List.map player model.players)


player : Player -> Html Msg
player player =
    li []
        [ i
            [ class "edit"
            , onClick (Edit player)
            ]
            []
        , div [] [ text player.name ]
        , button
            [ type_ "button"
            , onClick (Score player 2)
            ]
            [ text "2pt" ]
        , button
            [ type_ "button"
            , onClick (Score player 3)
            ]
            [ text "3pt" ]
        , div []
            [ text (toString player.points) ]
        ]


pointsTotal : Model -> Html Msg
pointsTotal model =
    let
        total =
            List.map .points model.plays
                |> List.sum
    in
        footer []
            [ div [] [ text "Total: " ]
            , div [] [ text (toString total) ]
            ]


playerForm : Model -> Html Msg
playerForm model =
    Html.form [ onSubmit Save ]
        [ input
            [ type_ "text"
            , placeholder "Add/Edit Player..."
            , onInput Input
            , value model.name
            ]
            []
        , button [ type_ "submit" ] [ text "Save" ]
        , button [ type_ "cancel", onClick Cancel ] [ text "Cancel" ]
        ]


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = initModel
        , view = view
        , update = update
        }
