SMODS.Atlas {
    key = "MaeveJokerAtlas",
    path = "JokerAtlas.png",
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = "goldenHour",
    loc_txt = {
        name = "Golden Hour",
        text = {
            "Each played {C:attention}5{}, {C:attention}6{}, or {C:attention}7{}",
            "gives {C:money}$#1#{}",
            "Gain {C:money}$#2#{} at the end of",
            "round if it's currently",
            "the {C:attention}Golden Hour{}",
            "{C:inactive}(roughly){}"
        },
    },
    config = { extra = { money_amount = 2, bonus = 4 } },
    rarity = 2,
    atlas = "MaeveJokerAtlas",
    pos = { x = 0, y = 0 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money_amount, card.ability.extra.bonus } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 5 or context.other_card:get_id() == 6 or context.other_card:get_id() == 7 then
                return {
                    dollars = card.ability.extra.money_amount,
                    card = card
                }
            end
        end
    end,

    calc_dollar_bonus = function(self, card)
		local bonus = card.ability.extra.bonus

        if os.date("%H") ~= (17 or 18 or 19) then
            bonus = 0
        end

		if bonus > 0 then return bonus 
        end
	end
}

SMODS.Joker {
    key = "loadAndPull",
    loc_txt = {
        name = "Load and Pull!",
        text = {
            "Each {C:attention}glass{} card held in",
            "hand while scoring loads",
            "up a retrigger for all",
            "cards scored in the",
            "{C:attention}next hand{}",
            "{C:inactive}(Shots loaded:{} {C:attention}#1#{}{C:inactive}/3){}",
            "{C:inactive}Cleaned new each blind!{}"
        }
    },

    config = { extra = { retriggers = 0 } },
    
    rarity = 3,
    pos = { x = 1, y = 0 },
    atlas = "MaeveJokerAtlas",
    cost = 8,
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.retriggers } }
    end,

    calculate = function(self, card, context)

        function CheckHand()
            card.ability.extra.retriggers = 0
            
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.ability.name == "Glass Card" then
                    card.ability.extra.retriggers = card.ability.extra.retriggers + 1
                end
            end

            if card.ability.extra.retriggers > 3 then
                card.ability.extra.retriggers = 3
            end
        end

        if context.individual and context.cardarea == G.hand then
            CheckHand()
        end

        if context.repetition and not context.repetition_only then
            if context.cardarea == G.play then
                return {
                    message = "Pull!",
                    repetitions = card.ability.extra.retriggers,
                    card = context.other_card
                }
            end
        end

        if context.after and card.ability.extra.retriggers > 0 and not context.end_of_round then
            return {
                message = "Loaded!",
                card = card
            }
        end

        if context.setting_blind then
            card.ability.extra.retriggers = 0

            if context.cardarea == G.jokers then
                return {
                    message = "Clean!"
                }
            end
        end
    end
}

SMODS.Joker {
    key = "puffPuffPass",
    loc_txt = {
        name = "Puff, Puff, Pass",
        text = {
            "{C:mult}+#3#{} Mult for every {C:attention}face{}",
            "card drawn at the start",
            "of the blind",
            "{C:mult}-#2#{} Mult when a {C:attention}face{}",
            "card is scored",
            "{C:inactive}Resets every round{}",
            "{C:inactive}(Currently {C:mult}+#1#{}{C:inactive} Mult){}"
        }
    },

    config = { extra = { current_mult = 0, mult_loss = 2, mult_gain = 4, check_handsize = false, handsize_update = 0 } },
    
    rarity = 1,
    pos = { x = 2, y = 0 },
    atlas = "MaeveJokerAtlas",
    cost = 4,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.current_mult, card.ability.extra.mult_loss, card.ability.extra.mult_gain, card.ability.extra.check_handsize, card.ability.extra.handsize_update} }
    end,

    calculate = function(self, card, context)

        if context.first_hand_drawn then
            card.ability.extra.check_handsize = true
        end

        if context.joker_main then
            card.ability.extra.check_handsize = false
            card.ability.extra.handsize_update = 0

            if card.ability.extra.current_mult > 0 then
                return {
                    mult_mod = card.ability.extra.current_mult,
                    message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.current_mult } }
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:is_face() then
                card.ability.extra.current_mult = card.ability.extra.current_mult - card.ability.extra.mult_loss

                if card.ability.extra.current_mult < 0 then
                    card.ability.extra.current_mult = 0
                end
            end
        end

        if context.end_of_round and not context.game_over then
            card.ability.extra.current_mult = 0
        end
    end,

    update = function(self, card)
        if card.ability.extra.check_handsize
        and G.GAME.current_round.hands_played == 0 
        and G.GAME.current_round.discards_used == 0 
        and next(G.hand.cards) ~= nil 
        and card.ability.extra.handsize_update < #G.hand.cards

        then
            card.ability.extra.current_mult = 0

            for _, handCard in ipairs(G.hand.cards) do
                if handCard:is_face(true) then
                    card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.mult_gain
                end
            end

            card.ability.extra.handsize_update = #G.hand.cards
        end
    end
}

SMODS.Joker {
    key = "onePickyGuy",
    loc_txt = {
        name = "One Picky Guy",
        text = {
            "Regain {C:chips}+1{} Hand if",
            "played hand is not the",
            "most played {C:attention}poker hand{}",
            "{C:inactive}(upto {}{C:attention}#1#{} {C:inactive}times per round){}"
        }
    },

    config = { extra = { max_given_hands = 2, current_given_hands = 0 } },
    
    rarity = 2,
    pos = { x = 3, y = 0 },
    atlas = "MaeveJokerAtlas",
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.max_given_hands, card.ability.extra.current_given_hands } }
    end,

    calculate = function(self, card, context)
        local played_most_played_hand = true
        local play_more_than = 0

        if context.before then
            play_more_than = (G.GAME.hands[context.scoring_name].played or 0)

            for k, v in pairs(G.GAME.hands) do
                if k ~= context.scoring_name and v.played >= play_more_than and v.visible then
                    played_most_played_hand = false
                end
            end

            if not played_most_played_hand and card.ability.extra.current_given_hands < card.ability.extra.max_given_hands then
                card.ability.extra.current_given_hands = card.ability.extra.current_given_hands + 1
                ease_hands_played(1)

                return {
                    message = "+1 Hand!",
                }
            end
        end

        if context.end_of_round and not context.game_over then
            card.ability.extra.current_given_hands = 0
        end
    end
}

SMODS.Joker {
    key = "jestingHour",
    loc_txt = {
        name = "The Jesting Hour",
        text = {
            "Gain Mult and Chips",
            "equal to the current {C:attention}hours{}",
            "and {C:attention}minutes{} on the clock",
            "{C:inactive}(Currently {}{C:mult}#1#{}{C:inactive}:{}{C:chips}#2#{}{C:inactive}){}"
        }
    },

    rarity = 2,
    pos = { x = 4, y = 0},
    atlas = "MaeveJokerAtlas",
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    config = { extra = { current_hour = 0, current_minutes = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.current_hour, card.ability.extra.current_minutes } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult_mod = os.date("%H"),
                chip_mod = os.date("%M"),
                message = os.date('%H:%M')
            }
        end
    end,

    update = function (self, card)
        card.ability.extra.current_hour = os.date("%H")
        card.ability.extra.current_minutes = os.date("%M")
    end
}

SMODS.Joker {
    key = "burningBridges",
    loc_txt = {
        name = "Burning Bridges",
        text = {
            "Score {X:mult,C:white}X0.1{} Mult for",
            "every rank between the",
            "{C:attention}highest{} and the {C:attention}lowest{}",
            "ranked card in the",
            "scoring hand"
        }
    },

    rarity = 2,
    pos = { x = 5, y = 0 },
    atlas = "MaeveJokerAtlas",
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    config = { extra = { current_mult = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.current_mult } }
    end,

    calculate = function(self, card, context)
        -- Ace is 14 by default
        local lowest_played_rank = 14
        local highest_played_rank = 0
        local this_cards_rank = 0

        if context.individual and context.cardarea == G.play then
            for i, scoring_card in ipairs(context.scoring_hand) do
                this_cards_rank = scoring_card:get_id()

                if this_cards_rank == 14 then
                    this_cards_rank = 1
                end

                if this_cards_rank < lowest_played_rank then
                    lowest_played_rank = this_cards_rank
                end

                if this_cards_rank > highest_played_rank then
                    highest_played_rank = this_cards_rank
                end
            end

            card.ability.extra.current_mult = 1 + (0.1 * (highest_played_rank - lowest_played_rank))
        end

        if context.joker_main and card.ability.extra.current_mult ~= 1 then
            return {
                Xmult = card.ability.extra.current_mult
            }
        end
    end
}

SMODS.Joker {
    key = "pullingTheHook",
    loc_txt = {
        name = "Pulling the Hook",
        text = {
            "{X:mult,C:white}X#1#{} Mult",
            "Discard all cards {C:attention}held{}",
            "{C:attention}in hand{} after hand is",
            "scored"
            }
    },

    pos = { x = 0, y = 1 },
    atlas = "MaeveJokerAtlas",
    rarity = 3,
    cost = 8,

    config = { extra = { xmult = 3, discard_flag = false, previous_selection_limit = 5 } },

    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.discard_flag, card.ability.extra.previous_selection_limit } }
    end,

    calculate = function(self, card, context)
        card.ability.extra.previous_selection_limit = G.hand.config.highlighted_limit

        if context.after and not context.blueprint then
            G.E_MANAGER:add_event(Event({ func = function()
                local any_selected = nil
                G.hand.config.highlighted_limit = #G.hand.cards

                for i = 1, #G.hand.cards do
                    if G.hand.cards[i] then 
                        G.hand:add_to_highlighted(G.hand.cards[i], true)
                        any_selected = true
                        play_sound('card1', 1)
                    end
                end

                if any_selected then
                    card.ability.extra.discard_flag = true
                end
                return true
            end }))

        end

        if context.joker_main then
            return {
                Xmult = card.ability.extra.xmult
            }
        end

        if context.end_of_round or context.setting_blind then
            card.ability.extra.discard_flag = false
        end
    end,

    update = function(self, card, context)
        if (G.STATE == 3 and card.ability.extra.discard_flag) then
            
            ease_discard(1)
            G.FUNCS.discard_cards_from_highlighted()

            if card.ability.extra.previous_selection_limit > 5 then
                card.ability.extra.previous_selection_limit = 5
            end

            G.hand.config.highlighted_limit = card.ability.extra.previous_selection_limit
            card.ability.extra.discard_flag = false
        end
    end
}