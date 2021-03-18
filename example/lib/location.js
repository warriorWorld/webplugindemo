function getLocation () {
    // 百度地图API功能
       var geolocation = new BMap.Geolocation();
       geolocation.getCurrentPosition(function(r){
           if(this.getStatus() == BMAP_STATUS_SUCCESS){
                var geoc = new BMap.Geocoder();
                geoc.getLocation(r.point, function(rs){
                    var addComp = rs.addressComponents;
                    locationSuccess(r.point.lng,r.point.lat,addComp.province , addComp.city , addComp.district ,addComp.street ,addComp.streetNumber);
                });
           }
           else {
               return null;
           }
       },{enableHighAccuracy: true})
}

window.alertMessage=function (text) {
    alert(text)
}

window.logger = (flutter_value) => {
   console.log({ js_context: this, flutter_value });
}