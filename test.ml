open OUnit2
open Map
open Territory
open Card
open Player
open ANSITerminal
open Command

(********************************************************************
   BEGIN: Helper functions from A2
 ********************************************************************)

(** [cmp_set_like_lists lst1 lst2] compares two lists to see whether
    they are equivalent set-like lists.  That means checking two things.
    First, they must both be {i set-like}, meaning that they do not
    contain any duplicates.  Second, they must contain the same elements,
    though not necessarily in the same order. *)
let cmp_set_like_lists lst1 lst2 =
  let uniq1 = List.sort_uniq compare lst1 
  in
  let uniq2 = List.sort_uniq compare lst2 
  in
  List.length lst1 = List.length uniq1
  &&
  List.length lst2 = List.length uniq2
  &&
  uniq1 = uniq2

(** [pp_string s] pretty-prints string [s]. *)
let pp_string s = "\"" ^ s ^ "\""

(** [pp_list pp_elt lst] pretty-prints list [lst], using [pp_elt]
    to pretty-print each element of [lst]. *)
let pp_list pp_elt lst =
  let pp_elts lst =
    let rec loop n acc = function
      | [] -> acc
      | [h] -> acc ^ pp_elt h
      | h1 :: (h2 :: t as t') ->
        if n = 100 then acc ^ "..."  (* stop printing long list *)
        else loop (n + 1) (acc ^ (pp_elt h1) ^ "; ") t'
    in loop 0 "" lst
  in "[" ^ pp_elts lst ^ "]"

let world_json = Yojson.Basic.from_file "worldmap.json"
let map = Map.json_to_map world_json
let alaska = map 
             |> Map.get_territories 
             |> List.hd
let greenland = List.nth (Map.get_territories map) 2

let player = Player.init "playerA" (ANSITerminal.Background (Red))
             |> Player.add_territory alaska 
             |> Player.add_troops 1

let playerB = Player.init "playerA" (ANSITerminal.Background (Red))
let card = Card.init "Alaska"
let card = Card.add_territory card alaska

let map_tests =
  [

  ]

let territory_name_test
    (description : string)
    (territory : Territory.t)
    (expected_output : string) : test =
  description >:: (fun _ ->
      assert_equal expected_output (Territory.get_name alaska))

let territory_owner_test
    (description : string)
    (territory : Territory.t)
    (expected_output : string) : test =
  description >:: (fun _ ->
      assert_equal expected_output (Territory.get_owner alaska))

let territory_troops_test
    (description : string)
    (territory : Territory.t)
    (expected_output : int) : test =
  description >:: (fun _ ->
      assert_equal expected_output (Territory.get_count alaska)
        ~printer:string_of_int)

let territory_neighbors_test
    (description : string)
    (territory : Territory.t)
    (expected_output : 'a list) : test =
  description >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists ~printer:(pp_list pp_string)
        expected_output (Territory.get_neighbors alaska))

let territory_set_owner_test
    (description : string)
    (territory : Territory.t)
    (terr_owner: string)
    (expected_output : string) : test =
  description >:: (fun _ ->
      assert_equal expected_output ("Me" 
                                    |> Territory.set_owner alaska 
                                    |> Territory.get_owner)
    )

let territory_set_count_test
    (description : string)
    (territory : Territory.t)
    (troop_count: int)
    (expected_output : int) : test =
  description >:: (fun _ ->
      assert_equal expected_output (10 
                                    |> Territory.set_count alaska 
                                    |> Territory.get_count)
    )

let territory_tests =
  [
    territory_name_test "name of alaska" alaska "Alaska";
    territory_owner_test "prints none" alaska "None";
    territory_troops_test "prints 1" alaska 0;
    territory_neighbors_test "prints playerA's neighbors list" alaska
      ["Kamchatka"; "Northwest_Terr"; "Alberta"];
    territory_set_owner_test "add owner to Alaska" alaska "Me" "Me";
    territory_set_count_test "add troops to Alaska" alaska 10 10;
  ]

let card_name_test
    (description : string)
    (card : Card.t)
    (expected_output : string) : test =
  description >:: (fun _ ->
      assert_equal expected_output (Card.get_name card))

let terr_to_str_lst terr =
  List.map (fun territory -> Territory.get_name territory) terr

let card_valid_locations_test
    (description : string)
    (card : Card.t)
    (expected_output : 'a list) : test =
  description >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists ~printer:(pp_list pp_string)
        expected_output (terr_to_str_lst (Card.get_valid_locs card)))

let card_tests =
  [
    card_name_test "prints Alaska" card "Alaska";
    card_valid_locations_test "prints ['Alaska']" card
      ["Alaska"];
  ]

let player_name_test
    (description : string)
    (player : Player.t)
    (expected_output : string) : test =
  description >:: (fun _ ->
      assert_equal expected_output (Player.get_name player))

let player_troops_test
    (description : string)
    (player : Player.t)
    (expected_output : int) : test =
  description >:: (fun _ ->
      assert_equal expected_output (Player.get_count player)
        ~printer:string_of_int)

let player_territories_test
    (description : string)
    (player : Player.t)
    (expected_output : 'a list) : test =
  description >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists ~printer:(pp_list pp_string)
        expected_output (terr_to_str_lst (Player.get_territories player)))

let player_add_territory_test
    (description : string)
    (player : Player.t ) (territory : Territory.t)
    (expected_output : 'a list) : test =
  description >:: (fun _ ->
      let p_new = Player.add_territory territory player 
      in
      assert_equal ~cmp:cmp_set_like_lists ~printer:(pp_list pp_string)
        expected_output (terr_to_str_lst (Player.get_territories p_new)))

let player_styles_test
    (description : string)
    (player : Player.t)
    (expected_output : 'a list) : test =
  description >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists 
        expected_output (Player.get_styles player))

let player_add_cards_test
    (description : string)
    (player : Player.t)
    (expected_output : int) : test =
  description >:: (fun _ ->
      assert_equal expected_output (Player.get_cards player)
        ~printer:string_of_int)

let player_set_cards_test
    (description : string)
    (player : Player.t)
    (expected_output : int) : test =
  description >:: (fun _ ->
      assert_equal expected_output (Player.get_cards player)
        ~printer:string_of_int)

let player_with_add_cards = Player.init "playerA" (ANSITerminal.Background (Red))
                            |> Player.add_territory alaska 
                            |> Player.add_troops 1

let _ = Player.add_card player_with_add_cards
let _ = Player.add_card player_with_add_cards
let _ = Player.add_card player_with_add_cards

let player_with_set_cards = Player.init "playerA" (ANSITerminal.Background (Red))
                            |> Player.add_territory alaska 
                            |> Player.add_troops 1

let _ = Player.set_cards player_with_set_cards 6


let player_tests =
  [
    player_name_test "prints playerA" player "playerA";
    player_troops_test "prints 1" player 1;
    player_territories_test "prints ['Alaska']" player ["Alaska"];
    player_add_territory_test "prints ['Greenland'; 'Alaska']" 
      player greenland ["Greenland"; "Alaska"];
    player_styles_test "player style" player [Bold; Background(Red)];
    player_add_cards_test "get number of cards" player_with_add_cards 3;
    player_set_cards_test "get number of cards" player_with_set_cards 6;
  ]






(*COMMAND TESTS *)

let string_of_command input_command = 
  match input_command with
  | Command.Attack { from_trr_name = x; to_trr_name = y} -> 
    "attack from " ^ x ^ " to " ^ y
  | Command.Place { count; trr_name} -> 
    "place " ^ string_of_int count ^ " to " ^ trr_name
  | Command.Fortify { count; from_trr_name; to_trr_name} -> 
    "fortify " ^ string_of_int count ^ " from " ^ 
    from_trr_name ^ " to " ^ to_trr_name
  | _ -> "invalid"

let string_of_raise input_command = 
  match input_command with
  | Malformed x -> x 
  | _ -> "An error outside of malformed"

let parse_test (description : string) string_command (expected_output) : test =
  description >:: (fun _ ->
      assert_equal expected_output 
        (string_command |> Command.parse |> string_of_command) 
        ~printer: (fun x -> x))

let parse_raise_exc_test (name : string) input
    (expected_output) : test = 
  name >:: (fun _ -> assert_raises expected_output (fun x -> input |> Command.parse));;

let parse_tests = [
  parse_test "place 10 to x" "place 10 x" "place 10 to x";
  parse_test "fortify 10 from x to y" "fortify 10 x y" "fortify 10 from x to y";

  parse_raise_exc_test "invalid place" "place x 10" 
    (Malformed "Malformed place command; please try again");

  parse_raise_exc_test "invalid fortify" "fortify x to y 10"  
    (Malformed "Malformed fortify command; please try again");
]

let check_reachability_tests = [

]

let suite =
  "test suite for Risk-OCaml" >::: List.flatten [
    map_tests;
    territory_tests;
    card_tests;
    player_tests;
    parse_tests;
  ]

let _ = run_test_tt_main suite