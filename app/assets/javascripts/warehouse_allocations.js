// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {
	$('#add-warehouse-assignment .spinner').hide();

	$("#ws-region-filter #region").change(function(){	
		
		var ftid = $(this).attr("data-ftid");
		var query_string = $.param({"region" : $('#region').val()});
		window.location.href = "/en/warehouse_selections/" + ftid + "?" + query_string;
	}); 

    $('#change-warehouse-allocation').on('shown.bs.modal', function (e) {
        e.preventDefault(); 

        var wai_id = $( e.relatedTarget ).data('wai-id'); 
		var woreda_name = $( e.relatedTarget ).data('woreda-name'); 
		var fdp_name = $( e.relatedTarget ).data('fdp-name');
		var requisition = $( e.relatedTarget ).data('requisition');
		var location_tree = $("#region option:selected").text() + ' > ' + $("#zone option:selected").text() + ' > ' + woreda_name + ' > ' + fdp_name
		var hub = $( e.relatedTarget ).data('hub');
		var hub_name = $( e.relatedTarget ).data('hub-name');
		var warehouse = $( e.relatedTarget ).data('warehouse');
		var warehouse_name = $( e.relatedTarget ).data('warehouse-name');
		// $('#modal-title').append(': \n' + $("#region option:selected").text() + ' > ' + $("#zone option:selected").text() + ' > ' + woreda_name + ' > ' + fdp_name);
		$('#change-warehouse-allocation #hub option[value="'+ hub + '"]').attr("selected", "selected");	
		$.ajax({
			url:"/warehouses/" + hub,
			dataType: 'json',
			success:function(json){
			  $('#change-warehouse-allocation #warehouse').html(' ');
			  $.each(json, function(i, value) {
				  if(warehouse==value['id'])
				  $('#change-warehouse-allocation #warehouse').append($('<option>').text(value['name']).attr('value', value['id']).attr('selected', 'selected'));
				  else
				  $('#change-warehouse-allocation #warehouse').append($('<option>').text(value['name']).attr('value', value['id']));				
			  });
		   }
		});
		$('#change-warehouse-allocation #warehouse option[value="' + warehouse + '"]').attr("selected", "selected");

		$('#change-warehouse-allocation .requisition_id').text(requisition);
		$('#change-warehouse-allocation .location_tree').text(location_tree);		
        $('#change-warehouse-allocation .spinner').show(); 
        $('#change-warehouse-allocation .form-container').hide(); 
		
		$('#changes-wa-btn').attr("data-wai-id", wai_id);

        $("#change-warehouse-allocation .form-container").load( '/hrds/new_hrd_item/' + hrd_id + '?zone_id=' + zone_id, function() { 
            $('#change-warehouse-allocation .spinner').hide(); 
            $('#change-warehouse-allocation .form-container').show(); 
        }); 
    });

    $('#change-warehouse-allocation').on('hidden.bs.modal', function () {
		$('#set_as_default').attr('checked', false);
		location.reload();
	});

    $('#changes-wa-btn').on('click', function (e) {
    	e.preventDefault();

    	var wai_id = $(this).attr("data-wai-id");
        var hub = $('#hub').val();
		var warehouse = $('#warehouse').val();
		var set_as_default = $('#set_as_default').is(':checked');

        if (wai_id!='' && wai_id!=null && hub!='' && hub!=null && warehouse!='' && warehouse!=null)
        {
        	$.ajax({
		        url:'/en/warehouse_allocations/change_wai',
		        type:'POST',
		        dataType:'json',
		        data:{
		        	warehouse_allocation: {
		        		wai_id: wai_id,
			            hub_id: hub,
						warehouse_id: warehouse,
						set_as_default: set_as_default
		        	}	            
		        },
		        before: function() {
		        	$('#change-warehouse-allocation .spinner').show(); 
		        	$('#change-warehouse-allocation .spinner').attr('style', 'color:#ff0').html('Loading...'); 
		        },
		        success:function(data){
		        	if ( $('#keep_creating').is(':checked') )
			        {
		            	$('#change-warehouse-allocation .spinner').attr('style', 'color:#18a689').html('Warehouse allocation was created successfully!');		            	
			        }
				    else
				    {
			        	$("#change-warehouse-allocation .close").click();		
				    }		             
		        },
		        error:function(data){
		            $('#change-warehouse-allocation .spinner').attr('style', 'color:#f00').html("Error: warehouse allocation was not successfully updated.");
		        }
		    });
        }
        else{
        	$('#change-warehouse-allocation .spinner').show(); 
        	$('#change-warehouse-allocation .spinner').attr('style', 'color:#f00').html("Error: please fill all fields and try again!");
        }
		$('#change-warehouse-allocation .spinner').delay(3000).fadeOut();
    });
});