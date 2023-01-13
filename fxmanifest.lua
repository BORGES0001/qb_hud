 shared_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"

fx_version "adamant"
devepoler "Maachado#6779 & BORGES0001"
game "gta5"

ui_page "nui/index.html"

client_scripts {
	"@vrp/lib/utils.lua",
	"client.lua"
} 

files {
	"nui/index.html",
	"nui/lang.js",
	"nui/script.js",
	"nui/gauge.min.js",
	"nui/style.css",
	"nui/images/*.png",
	"nui/sounds/*.ogg",
	"nui/fonts/*.ttf",
	"nui/fonts/*.svg",
	"nui/fonts/*.eot",
	"nui/fonts/*.woff",
	"nui/fonts/*.woff2",
	"nui/fonts/*.otf"
}                                                                      