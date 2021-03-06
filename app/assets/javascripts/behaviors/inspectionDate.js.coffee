App.registerBehavior 'InspectionDate'

class Behavior.InspectionDate
  constructor: ($el) ->
    @$el = $el
    $ul = $el.closest 'ul'
    @count = $ul.find('> li').length
    @$template = $ document.getElementById('template-inspectiondate').innerHTML
    @model_name = @$template.find('.form-control.inspection-date').attr('id').split("_", 1)
    $ul.on 'click', '.remove', @removeInspectionDate
    $el.click => @addNewInspectionDate()


  addNewInspectionDate: ->
    tmpl = @$template.clone()
    common_string = @model_name + '[inspection_dates_attributes]['
    date = common_string + @count + '][date]'
    tmpl.find('.inspection-date').attr('name', date)
    tmpl.find('.index').text @count++
    @$el.before tmpl
    if @count == 6
      $(".add-inspectiondate").hide()

  removeInspectionDate: ->
    li = $(@).closest 'li'
    id = '#' +@model_name + 'product_inspection_dates_attributes_' + $(@).data('index') + '_id'

    if $(id).length > 0
      li.find('[type=hidden]').attr 'value', true
      li.wrap '<div class="hide"></div>'
    else
      li.remove()
