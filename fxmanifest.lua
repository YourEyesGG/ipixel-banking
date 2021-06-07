fx_version 'adamant'
game 'gta5'
description 'iPixel Banking | Customized from new_banking'
author 'iPixel Development Team'

ui_page('client/html/ui.html')

server_scripts {  
    '@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locale.lua',
	'locales/en.lua',
	'config.lua',
	'server.lua'
}


client_scripts {
    '@es_extended/locale.lua',
	'locale.lua',
	'locales/en.lua', 
	'config.lua',
	'client/client.lua'
}

files {
	'client/html/ui.html',
    'client/html/style.css',
    'client/html/media/font/*.otf',
    'client/html/media/img/*.png',
    'client/html/media/img/*.jpg',
    'locale.js',
}
