lapis = require "lapis"

import respond_to, json_params from require "lapis.application"
import slack_tokens, slack_hook, error_channel, bot_name from require "secret"
import const_compare from require "helpers"

Messages = require "models.Messages"

class extends lapis.Application
    [update: "/update"]: respond_to {
        GET: =>
            @html ->
                p ->
                    text "Please look at the "
                    a href: "https://github.com/Guard13007/slackiver", "readme"
                    text " to see how to use this properly. :P"

        POST: json_params =>
            if const_compare @params.token, slack_tokens
                message = Messages\create {
                    team_id: @params.team_id
                    team_domain: @params.team_domain
                    channel_id: @params.channel_id
                    channel_name: @params.channel_name
                    timestamp: @params.timestamp
                    user_id: @params.user_id
                    user_name: @params.user_name
                    text: @params.text
                }
                --unless message
                os.execute "curl -X POST --data-urlencode 'payload={\"channel\": \"#slackiver\", \"username\": \"The Slackiver\", \"text\": \"Error occured saving message from #{@params.user_name}:\\\n#{@params.text}\\\nSent at #{@params.timestamp} in #{@params.channel_name}.\", \"icon_emoji\": \":warning:\"}' #{slack_hook}"
            --else
            --    return status: 404 -- I dunno who you think you are
    }

    [all: "/all"]: =>
        messages = Messages\select "ORDER BY timestamp DESC"
        @html ->
            if #messages > 0
                element "table", ->
                        for i in ipairs messages
                            tr ->
                                td messages[i].timestamp
                                td messages[i].team_domain
                                td messages[i].channel_name
                                td messages[i].user_name
                                td messages[i].text
