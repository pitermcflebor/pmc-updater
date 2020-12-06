fx_version 'cerulean'
games { 'gta5' }

server_only 'yes'

--[[

        THIS SCRIPT WAS MADE BY PITERMCFLEBOR
    DON'T CHANGE THE SCRIPT NAME OR REMOVE THIS SIGN

Remove Github API Limitation?
https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token#creating-a-token

Write your token inside '.authkey' file!

]]

auto 'no'  -- enable auto updates?

server_scripts {
    'utils.lua',
    'git.lua',
    'checker.lua',
}

pmc_updates 'yes'
pmc_github 'https://github.com/pitermcflebor/pmc-updater'
pmc_version 'v1.0'