$.widget "ui.geo_autocomplete", 
  _init: ->
    @options._geocoder = new google.maps.Geocoder
    @options._cache = {}
    @element.autocomplete @options
    @element.data("autocomplete")._renderItem = (_ul, _item) ->
      $("<li></li>").data("item.autocomplete", _item).append(@options.getItemHTML(_item)).appendTo _ul
  options:
    geocoder_region: ""
    geocoder_types: "locality,political,sublocality,neighborhood,country"
    geocoder_address: true
    mapwidth: 100
    mapheight: 100
    maptype: "terrain"
    mapsensor: false
    minLength: 3
    delay: 300
    source: (_request, _response) ->
      if _request.term of @options._cache
        _response @options._cache[_request.term]
      else
        self = this
        _address = _request.term + (if @options.geocoder_region then ", " + @options.geocoder_region else "")
        @options._geocoder.geocode address: _address, (_results, _status) ->
          _parsed = []
          if _results and _status and _status == "OK"
            _types = self.options.geocoder_types.split(",")
            $.each _results, (_key, _result) ->
              if $.map(_result.types, (_type) ->
                (if $.inArray(_type, _types) != -1 then _type else null)
              ).length and _result.geometry and _result.geometry.viewport
                if self.options.geocoder_address
                  _place = _result.formatted_address
                else
                  _place_parts = _result.formatted_address.split(",")
                  _place = _place_parts[0]
                  $.each _place_parts, (_key, _part) ->
                    unless _part.toLowerCase().indexOf(_request.term.toLowerCase()) == -1
                      _place = $.trim(_part)
                      false
                _parsed.push
                  value: _place
                  label: _result.formatted_address
                  viewport: _result.geometry.viewport
                  geoobject: _result
                  options: self.options
          self.options._cache[_request.term] = _parsed
          _response _parsed

    focus: (event, ui)  ->
      #console.log(ui.item.options)
      options = ui.item.options
      $("#"+options.params.direction+"_panel img").attr("src", "http://maps.google.com/maps/api/staticmap?visible=" + ui.item.viewport.getSouthWest().toUrlValue() + "|" + ui.item.viewport.getNorthEast().toUrlValue() + "&size=" + options.mapwidth + "x" + options.mapheight + "&maptype=" + options.maptype + "&sensor=" + (if options.mapsensor then "true" else "false"))
      $("#"+options.params.direction+"_panel h3").html(ui.item.value)
    getItemHTML: (_item) ->
      _src = "http://maps.google.com/maps/api/staticmap?visible=" + _item.viewport.getSouthWest().toUrlValue() + "|" + _item.viewport.getNorthEast().toUrlValue() + "&size=" + @mapwidth + "x" + @mapheight + "&maptype=" + @maptype + "&sensor=" + (if @mapsensor then "true" else "false")
      "<a>" + _item.label + "<br clear=\"both\" /></a>"
