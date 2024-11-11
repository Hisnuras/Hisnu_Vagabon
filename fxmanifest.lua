fx_version 'cerulean'
game 'gta5'

author 'VotreNom'
description 'Script FiveM standalone pour afficher une zone rectangulaire sur la carte'
version '1.0.0'

client_script {
    'blips.lua',
    'density.lua',
    'RemoveAnimal.lua',
    --'client.lua',
    'coord_display.lua',
    'time_command.lua'
}
server_script 'server.lua'
shared_script 'config.lua'
