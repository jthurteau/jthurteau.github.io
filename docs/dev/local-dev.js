$(function(){
    $('.debug_dump').addClass('debug_expandable')
      .on('click', function(){$(this).toggleClass('debug_expandable')});

  $('body').append(
    '<div id="candy" class="toolbag-toggle">'
    + '<a href="#"><span class="fa fa-bug"></span>'
    + '<span class="accessibleHidden">Show Testing Links</span></a>'
    + '</div>'
  );
  $('#candy').on('click', function(){$('#candy-target').toggleClass('active'); return false;});
  $('body').append('<div id="candy-target" class="toolbag-panel panel-abs panel-solid"><ul></ul></div>')
  var candy = $('#candy-target ul');
  populate(candy);
});

function populate(target)
{
 //#TODO get local-dev.json and do what it says for target.populate   
}
