App.registerBehavior 'CheckOutsideUS'

class Behavior.CheckOutsideUS
  constructor: ($el) ->
    @$el = $el

    @$variables = {
      'country': '#fly_buy_profile_country',
      'tin_number': '#fly_buy_profile_tin_number',
      'eic_attachment': '#fly_buy_profile_eic_attachment',
      'business_documents': '#fly_buy_profile_business_documents',
      'ssn_number': '#fly_buy_profile_ssn_number'
    }

    @$func = {
      'display_true': @show_and_changes,
      'display_false': @hide_and_changes
    }

    do @$func['display_' + $(@$el).is(':checked')]

    $(@$el).on 'ifChanged', => do @changes

  changes: =>
    do @$func['display_' + $(@$el).is(':checked')]

  show_and_changes: =>
    $(@$variables['country']).closest('.col-md-6').removeClass('hide')
    $(@$variables['tin_number']).closest('.form-group').find('label').text('Business Tax Number:')
    $(@$variables['eic_attachment']).closest('.form-group').find('label').text('Tax Document:')
    $(@$variables['eic_attachment']).closest('.form-group').find('a.view').addClass('hide')
    $(@$variables['business_documents']).closest('.col-md-6').removeClass('hide')
    $(@$variables['ssn_number']).closest('.form-group').find('label').text('GOVERNMENT IDENTIFICATION NUMBER:')

  hide_and_changes: =>
    $(@$variables['country']).closest('.col-md-6').addClass('hide')
    $(@$variables['tin_number']).closest('.form-group').find('label').text('EIN Number:')
    $(@$variables['eic_attachment']).closest('.form-group').find('label').text('EIN Document:')
    $(@$variables['eic_attachment']).closest('.form-group').find('a.view').removeClass('hide')
    $(@$variables['business_documents']).closest('.col-md-6').addClass('hide')
    $(@$variables['ssn_number']).closest('.form-group').find('label').text('SOCIAL SECURITY NUMBER:')