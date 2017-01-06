/*
* Tadas Juozapaitis ( kasp3rito@gmail.com )
*
* Modifed by Zazar:
* 24.06.2011 - Corrected pausing issue with multiple instances
*
*/

(function($){

$.fn.vTicker = function(options) {
	var defaults = {
		speed: 700,
		pause: 4000,
		showItems: 3,
		animation: '',
		mousePause: true,
		isPaused: false,
		maxHeight: 33
	};

	var options = $.extend(defaults, options);

	moveUp = function(obj2, height, paused){
		if(paused) return;
		
		var obj = obj2.children('ul');
		
	    	first = obj.children('li:first').clone(true);
    		obj.animate({top: '-=' + height + 'vh'}, options.speed, function() {
        		$(this).children('li:first').remove();
	        	$(this).css('top', '0vh');
        	});
		
		if(options.animation == 'fade') {
			obj.children('li:first').fadeOut(options.speed);
			obj.children('li:last').hide().fadeIn(options.speed);
		}

	    	first.appendTo(obj);
	};
	
	return this.each(function() {
		var obj = $(this);
		var maxHeight = 0;
		var itempause = options.isPaused;
		var maxHeight = options.maxHeight;

		obj.css({overflow: 'hidden', position: 'relative'})
			.children('ul').css({position: 'absolute', margin: 0, padding: 0});

		obj.children('ul').children('li').each(function() {
			$(this).height(maxHeight + "vh");
		});

		obj.height(maxHeight * options.showItems + "vh");
		
    		var interval = setInterval(function(){ moveUp(obj, maxHeight, itempause); }, options.pause);
		
		if (options.mousePause)
		{
			obj.bind("mouseenter",function() {
				itempause = true;
			}).bind("mouseleave",function() {
				itempause = false;
			});
		}
	});
};
})(jQuery);