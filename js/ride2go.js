           $().ready(function() {
                setgeotypes("whereto", ["premise", "subpremise", "route"]);
                setgeotypes("wherefrom", ["route", "premise", "subpremise", "locality"]);
                initInputBox({
                    region: "de",
                    direction: "to"
                });
                initInputBox({
                    region: "de",
                    direction: "from"
                });


                $.each(["to", "from"], function(i, d) {
                    $("#where" + d + " input").change(function() {
                        initInputBox({
                            direction: d
                        });
                    });
                    $("#where" + d + " .switcher").toggle(

                    function() {
                        $(this).html("- hide options");
                        $(this).parent().children(".details").show(100);
                    }, function() {
                        $(this).html("+ show options");
                        $(this).parent().children(".details").hide(200);
                    });
                });
            });

            function setgeotypes(boxname, types) {
                $.each(types, function(i, b) {

                    $("input[name='" + boxname + "'][value='" + b + "']").attr('checked', true);
                });
            }

            function geotypes(direction) {
                return $('input[name=where' + direction + ']:checked').map(function() {
                    return this.value;
                }).get();
            }

            function initInputBox(params) {
                // defining defaults 
                params = typeof(params) != 'undefined' ? params : {
                    region: "de",
                    direction: "to"
                };
                params.region = typeof(params.region) != 'undefined' ? params.region : "de";
                params.direction = typeof(params.direction) != 'undefined' ? params.direction : "to";

                var inputbox = $('#where' + params.direction + 'box').geo_autocomplete({
                    geocoder_region: params.region,
                    geocoder_address: true,
                    geocoder_types: geotypes(params.direction).join(","),
                    mapheight: 100,
                    mapwidth: 200,
                    MapTypeIdaptype: 'hybrid',
                    select: function(event, ui) {
                        l(ui.item);
                        enableFrom(params.direction);
                    },
                    //getItemHTML: function (_item) {
                    //    return "<a>yeah</a>";
                    //}
                });
                // fire up a search
                $(inputbox).autocomplete("search");
                //return inputbox;
            }
            function enableFrom (d) { 
                $("#where"+d).text(d+": "+$("#where"+d+"box").val());
            }
            // only for debugging

            function l(msg) {
                console.log(msg);
                //alert(msg);
            }
