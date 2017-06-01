var years = new Array();
var vals = new Array();
d3.json('results/messaging_timeline_formatted.json', function(error, data){
    var chart1 = c3.generate({
	bindto: '#chart1',
	data: {
	    x: 'x',
	    columns: data,
	},
	axis: {
	    x : {
		tick: {
		    fit: true
		}
	    }
	}
    });
});

