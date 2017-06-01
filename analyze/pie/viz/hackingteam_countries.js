d3.json('results/hackingteam_countries.json', function(error, data){
    var chart = c3.generate({
	bindto: '#chart1',
	data: {
	    columns: data,
	    type: 'pie'
	}
    });
});
