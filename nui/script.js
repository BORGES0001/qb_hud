let player = {
	life: 100,
	shield: 50,
	mic: 0,
	speaking: "Falando",
	street: "Rua dos guris",
	time: "18:00",
	headLights: 0,
	seatBelt: false,
	fuel: false,
	gear: "N",
	speed: 180,
	arrows: 0
}

let action
var firstLoad = true
var lastAction = false

var couponsInfos = {
	status: true,
	name: "VALENTINES",
	expire: "2022-06-12 23:59:00",
}

$(() => {
	window.addEventListener("message", function (event) {
		action = event.data;

		if (firstLoad) {
			firstLoad = false
			$(".server-header").css("display", "flex");
			$(".container").css("display", "flex");
			$(".street-container").css("display", "flex");
		}

		toggleHud(action.showHud);
	});

	window.addEventListener("offline", function () { // Quando a internet do jogador cai o evento é acionado.
		$("#displayNui").css("display", "flex") // Exibe a nui na tela do jogador.
		$.post("http://qb_hud/lock") // Manda a informação pro client para ele 'trabalhar'
	});

	window.addEventListener("online", function () { // Quando a internet do jogador volta o evento é acionado
		setTimeout(function () { // Timeout por conta do delay do FiveM
			$("#displayNui").css("display", "none") // Remove a nui da tela do jogador
			$.post("http://qb_hud/unlock") // Manda a informação pro client para ele 'trabalhar'
		}, 5000)
	});
});


const maxSpeed = 600;

var stopIndicatorAudio = false;

var seatBeltOnAudio = new Audio("sounds/seatbelt-buckle.ogg");
seatBeltOnAudio.volume = 0.5;

var seatBeltOffAudio = new Audio("sounds/seatbelt-unbuckle.ogg");
seatBeltOffAudio.volume = 0.5;

var vehicleIndicatorAudio = new Audio("sounds/car-indicators.ogg");
vehicleIndicatorAudio.volume = 0.5;

vehicleIndicatorAudio.addEventListener('ended', function () {
	if (!stopIndicatorAudio) {
		this.currentTime = 0;
		this.play();
	}
	stopIndicatorAudio = false;
}, false);


function updateSpeed(speed, rpm) {
	if (speed > maxSpeed) speed = maxSpeed;
	if (!speed) {
		speed = 0
	}
	speedText = speed.toString();

	if (speed < 10) {
		$('.current-speed').html(`<span class="speedHight">0</span>0${speed}`)
	} else if (speed < 100) {
		$('.current-speed').html(`<span class="speedHight">0</span>${speed}`)
	} else {
		$('.current-speed').html(`<span class="speedHight">${speedText.substring(0, 1)}</span>${speedText.substring(1, 2)}${speedText.substring(2, 3)}`)
	}

	var percentRpm = rpm * 100
	if (percentRpm > 100) {
		percentRpm = 100
	} else if (percentRpm < 0) {
		percentRpm = 0
	}

	var CalcRpm = (130 / 100) * percentRpm
	$('.level-right-fill').css({ 'stroke-dasharray': `${CalcRpm}, 120` })
}

function updateBar(bar, amount) {
	const bars = {
		life: $(".health .bar-progressbar"),
		shield: $(".armour .bar-progressbar"),
		hunger: $(".hunger .bar-progressbar"),
		thirst: $(".thirst .bar-progressbar")
	}
	let id = bars[bar];
	if (id && amount) {
		id.width(amount + "%");
	}
}

function updateMic(stats) {
	if (stats == true) {
		$(".mic").css("opacity", "1.0");
	} else {
		$(".mic").css("opacity", "0.5");
	}
}

function updateSpeaking(stats) {
	if (stats == 1) {
		$('.microphone-status').text('Baixo')
	}
	if (stats == 2) {
		$('.microphone-status').text('Médio')
	}
	if (stats == 3) {
		$('.microphone-status').text('Alto')
	}
	if (stats == 4) {
		$('.microphone-status').text('Desligado')
	}
}

function updateLocInfo(street, time) {
	if (street && time) {
		$(".street-title").text(street);
		$(".data-title").text(time);
	}
}

function updateFreqInfo(frequency) {
	if (frequency) {
		$('.radio-container').css('opacity', '1')
		$(".radio-status").text(frequency);
	}
}

function updateCompass(compass) {
	$('.compass').text(compass)
	if (compass == "N") {
		$('.rotate-arrow').css({ 'transform': 'rotate(-45deg)' });
	} else if (compass == "S") {
		$('.rotate-arrow').css({ 'transform': 'rotate(140deg)' });
	} else if (compass == "L") {
		$('.rotate-arrow').css({ 'transform': 'rotate(45deg)' });
	} else {
		$('.rotate-arrow').css({ 'transform': 'rotate(230deg)' });
		$('.rotate-arrow').css('margin-left', '0.3vw');
	}
}


function updateSeatBelt(stats) {
	if (stats !== undefined) {
		if (stats) {
			$('.belt-icon').css('fill', '#e89e29')
		} else {
			$('.belt-icon').css('fill', 'white')
		}
	}
}

function updateLock(stats) {
	if (stats !== undefined) {
		if (stats) {
			$('.key-icon').css('color', '#e89e29')
		} else {
			$('.key-icon').css('color', 'white')
		}
	}
}

function updateFuel(fuelLevel) {
	if (fuelLevel !== undefined) {
		if (fuelLevel) {
			var percentFuel = parseInt(fuelLevel)
			var fuelCalc = (130 / 100) * percentFuel

			$('.level-left-fill').css({ 'stroke-dasharray': `${fuelCalc}, 120` })
		}
	}
}

function updateEngine(engineLevel) {
	if (engineLevel !== undefined) {
		if (engineLevel) {
			let engine = parseInt(engineLevel);
			$('.motor-progressbar').height(engine + "%");
		}
	}
}

function timeDifference(d1, d2) {
	var difference = d1 - d2
	
	var nameDay = "DIA"
	var days = Math.round(difference / (24 * 60 * 60 * 1000))
	if (days > 1) {
	 nameDay = "DIAS"
	}
	difference = difference % (24 * 60 * 60 * 1000)


	var hours = Math.round(difference / (60 * 60 * 1000))
	if (hours < 10) {
		hours = "0" + hours
	}
	difference = difference % (60 * 60 * 1000)


	var minutes = Math.round(difference / (60 * 1000))
	if (minutes < 10) {
		minutes = "0" + minutes
	}
	difference = difference % (60 * 1000)

	var seconds = Math.round(difference / (1000))
	if (seconds < 10) {
		seconds = "0" + seconds
	}

	return `${days} ${nameDay} | ${hours}:${minutes}:${seconds}`
}

updateCoupons()
function updateCoupons() {
	if (couponsInfos.status && couponsInfos.name && couponsInfos.expire) {
		var d1 = new Date(couponsInfos.expire).getTime();
    	var d2 = new Date().getTime();
		var difference = d1 - d2
		if (difference > 0) {
			$(".coupons").css("display", "flex");
			
			$(".coupons-name").text(couponsInfos.name);
			$(".coupons-time").text(timeDifference(d1, d2));
		} else {
			$(".coupons").css("display", "none");
		}
	}
}

function setInfo(player) {
	updateBar("life", player.life)
	updateBar("shield", player.shield)
	updateBar("hunger", player.hunger)
	updateBar("thirst", player.thirst)
	updateMic(player.mic)
	updateSpeaking(player.speaking)
	updateFreqInfo(player.frequency)
	updateCompass(player.compass)
	updateLocInfo(player.street, player.time)
	updateSeatBelt(player.seatBelt)
	updateLock(player.seatLock)
	updateFuel(player.fuel)
	updateEngine(player.engine);
	updateSpeed(player.speed, player.rpm)
	toggleSpeedometer(player.vehicle)
	updateCoupons()
}


var time = 0
function opacityMod(time) {
	time = time
	window.setTimeout( opacityMod, 1000 );
}

function toggleSpeedometer(bool) {
	if (bool) {
		if (lastAction) {
			lastAction = false
			$(".container-speedmeter").css("opacity", "0");
			$('.level-left').css('animation-name', 'leftToLeft')
			$('.level-right').css('animation-name', 'rightToRight')
			$('.speedmeter-center').css('animation-name', 'speedcontainertrue')
			$('.container-speedmeter').css('animation-name', 'speedmetertrue')

			/* opacityMod(10000) */
			setTimeout(function () {
				$(".container-speedmeter").css("opacity", "1");
			}, 3000)

		} else {
			$('.level-left').css('animation-name', 'leftToLeft')
			$('.level-right').css('animation-name', 'rightToRight')
			$('.speedmeter-center').css('animation-name', 'speedcontainertrue')
			$('.container-speedmeter').css('animation-name', 'speedmetertrue')
		}
	} else {
		if (lastAction) {
			lastAction = false
			$(".container-speedmeter").css("opacity", "0");
			$('.level-left').css('animation-name', 'leftToRight')
			$('.level-right').css('animation-name', 'rightToLeft')
			$('.speedmeter-center').css('animation-name', 'speedcontainerfalse')
			$('.container-speedmeter').css('animation-name', 'speedmeterfalse')

			/* opacityMod(10000) */
			setTimeout(function () {
				$(".container-speedmeter").css("opacity", "1");
			}, 3000)
		} else {
			$('.level-left').css('animation-name', 'leftToRight')
			$('.level-right').css('animation-name', 'rightToLeft')
			$('.speedmeter-center').css('animation-name', 'speedcontainerfalse')
			$('.container-speedmeter').css('animation-name', 'speedmeterfalse')
		}
	}
}

function toggleHud(bool) {
	if (bool) {
		$(".container").fadeIn(500);
		$(".container-header").fadeIn(500);
		$(".street-container").fadeIn(500);
		setInfo(action);
	} else {
		lastAction = true
		$(".container").fadeOut(500);
		$(".container-header").fadeOut(500);
		$(".street-container").fadeOut(500);
	}
}