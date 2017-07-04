
/**
 * Copyright © 2017 Tino Reichardt (milky at Open-Digital-Signage dot org)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2, as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Based on code by Tadas Juozapaitis <kasp3rito at gmail.com> and Zazar
 * Homepage: https://github.com/mcmilk/jquery.vticker/
 */

(function($){

$.fn.vTicker = function(options) {
	var defaults = {
		speed: 700,
		pause: 4000,
		showItems: 3,
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
	});
};

})(jQuery);
