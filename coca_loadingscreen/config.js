/*
    This script was developed by Piter Van Rujpen/TheGamerRespow for Vulkanoa (https://discord.gg/bzMnYPS).
    Do not re-upload this script without my authorization. (I only give authorization by PM on FiveM.net (https://forum.fivem.net/u/TheGamerRespow))
*/

var VK = new Object(); // DO NOT CHANGE
VK.server = new Object(); // DO NOT CHANGE

VK.backgrounds = new Object(); // DO NOT CHANGE
VK.backgrounds.actual = 0; // DO NOT CHANGE
VK.backgrounds.way = true; // DO NOT CHANGE
VK.config = new Object(); // DO NOT CHANGE
VK.tips = new Object(); // DO NOT CHANGE
VK.music = new Object(); // DO NOT CHANGE
VK.info = new Object(); // DO NOT CHANGE
VK.social = new Object(); // DO NOT CHANGE
VK.players = new Object(); // DO NOT CHANGE 

//////////////////////////////// CONFIG

VK.config.loadingSessionText = "Sunucu Yükleniyor..."; // Loading session text
VK.config.firstColor = [0, 191, 255]; // First color in rgb : [r, g, b]
VK.config.secondColor = [255, 150, 0]; // Second color in rgb : [r, g, b]
VK.config.thirdColor = [52, 152, 219]; // Third color in rgb : [r, g, b]

VK.backgrounds.list = [ // Backgrounds list, can be on local or distant(http://....)
    'img/bg-1.png',
    'img/bg-2.png',
    'img/bg-3.png',
	'img/bg-4.png',
	'img/bg-5.png',
	'img/bg-6.png',
];
VK.backgrounds.duration = 4500; // Background duration (in ms) before transition (the transition lasts 1/3 of this time)


VK.music.url = "music.mp3"; // Music url, can be on local or distant(https://www.youtube.com/watch?v=rpgQD40SIwA) ("NONE" to desactive music)
VK.music.volume = 0.5; // Music volume (0-1)
VK.music.title = ""; // Music title ("SPACE" to desactive)
VK.music.submitedBy = ""; // Music submited by... ("NONE" to desactive)

VK.info.logo = "icon/icon.png"; // Logo, can be on local or distant(http://....) ("NONE" to desactive)
VK.info.text = ""; // Bottom right corner text ("NONE" to desactive) 
VK.info.website = ""; // Website url ("NONE" to desactive) 
VK.info.ip = ""; // Your server ip and port ("ip:port")

VK.social.discord = ""; // Discord url ("NONE" to desactive)
VK.social.twitter = ""; // Twitter url ("NONE" to desactive)
VK.social.facebook = ""; // Facebook url ("NONE" to desactive)
VK.social.youtube = ""; // Youtube url ("NONE" to desactive)
VK.social.twitch = ""; // Twitch url ("NONE" to desactive<)

VK.players.enable = false; // Enable the players count of the server (true : enable, false : prevent)
VK.players.multiplePlayersOnline = "@players joueurs en ligne"; // @players equals the players count
VK.players.onePlayerOnline = "1 joueur en ligne"; // Text when only one player is on the server
VK.players.noPlayerOnline = "Aucun joueur en ligne"; // Text when the server is empty

////////////////////////////////
