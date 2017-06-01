d3.json('results/us_topics.json', function(error, data){
    var chart = c3.generate({
	bindto: '#chart1',
	data: {
	    columns: data,
	    type: 'pie'
	}
    });
});
