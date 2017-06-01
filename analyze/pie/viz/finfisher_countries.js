d3.json('results/finfisher_countries.json', function(error, data){
    var chart = c3.generate({
	bindto: '#chart1',
	data: {
	    columns: data,
	    type: 'pie'
	}
    });
});
