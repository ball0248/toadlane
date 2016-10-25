#= require jquery
#= require jquery_ujs
#= require jquery-ui/slider
#= require jquery-ui/selectmenu
#= require jquery-ui/tooltip
#= require jquery-ui/autocomplete
#= require html5lightbox

#= require jquery.bxslider.min

#= require ./plugins/jquery.validate
#= require_tree ../../../vendor/assets/javascripts/.
#= require_tree ./plugins

#= require bootstrap

#= require elemental

#= require_tree ./initializers/
#= require_tree ./helpers/
#= require_tree ./behaviors/

$(document).ready ->
  Elemental.addNamespace App
  Elemental.load document
  $(".fe-toggle").tooltip({tooltipClass: "search-tooltip"})
  $('.bxslider').bxSlider
    slideWidth: 240
    minSlides: 1
    maxSlides: 4
    slideMargin: 38
    moveSlides: 1
    pager: false
  $("#user_state").autocomplete({
    source: ["Alabama",
    "Alaska",
    "Arizona",
    "Arkansas",
    "California",
    "Colorado",
    "Connecticut",
    "Delaware",
    "District of Columbia",
    "Florida",
    "Georgia",
    "Hawaii",
    "Idaho",
    "Illinois",
    "Indiana",
    "Iowa",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Maine",
    "Maryland",
    "Massachusetts",
    "Michigan",
    "Minnesota",
    "Mississipi",
    "Missouri",
    "Montana",
    "Nebraska",
    "Nevada",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "New York",
    "North Carolina",
    "North Dakota",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Vermont",
    "Virginia",
    "Washington",
    "West Virginia",
    "Wisconsin",
    "Wyoming"
    ],
    autocomplete: true
  });

  $(".html5lightbox").html5lightbox()

  $('#set_new_inspection').click ->
    if $(".set_inspection_date").is(':visible')
      $(".set_inspection_date").hide()
      $(".confirm-inspection-date-btn").show()
    else
      $(".set_inspection_date").show()
      $(".confirm-inspection-date-btn").hide()

  $('.related_searches a').click (event) ->
    event.preventDefault()
    rs = $(this).html()
    $('input#query').val(rs)
    $('form#search_form').submit()
    return

  $("#green_order_phone").mask("999-999-9999");

  if $('.vp-calculation-checkout').is(':visible')
    $('input[name="stripe_order[shipping_estimate_id]"]:first, input[name="green_order[shipping_estimate_id]"]:first, input[name="amg_order[shipping_estimate_id]"]:first, input[name="emb_order[shipping_estimate_id]"]:first').trigger('click');

  jQuery.validator.addMethod 'zipcode', ((value, element) ->
    @optional(element) or /^\d{5}(?:-\d{4})?$/.test(value)
  ), 'Please provide a valid zipcode.'

  jQuery.validator.addMethod 'validEmail', ((value, element) ->
    @optional(element) or /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i.test(value)
  ), 'Please enter a valid email address.'

  jQuery.validator.addMethod 'filesize', ((value, element, param) ->
    mult_param = param * 1048576
    @optional(element) or (element.files[0].size <= mult_param)
  ), 'File size must be less than {0} MB'

  $('select#green_order_address_country').change (event) ->
    select_wrapper = $('.order_state_code_wrapper')

    $('select', select_wrapper).attr('disabled', true)

    country_code = $(this).val()

    url = "/products/subregion_options?parent_region=#{country_code}&parent_object_sym=green_order"
    select_wrapper.load(url)

  $('.inspection_date_select').children().closest('label').find('input:first').prop("checked", true)

  $('select#amg_order_address_country').change (event) ->
    select_wrapper = $('.order_state_code_wrapper')

    $('select', select_wrapper).attr('disabled', true)

    country_code = $(this).val()

    url = "/products/subregion_options?parent_region=#{country_code}&parent_object_sym=amg_order"
    select_wrapper.load(url)

  $('select#emb_order_address_country').change (event) ->
    select_wrapper = $('.order_state_code_wrapper')

    $('select', select_wrapper).attr('disabled', true)

    country_code = $(this).val()

    url = "/products/subregion_options?parent_region=#{country_code}&parent_object_sym=emb_order"
    select_wrapper.load(url)

  $('form#new_green_order').validate
    rules:
      "green_order[email_address]":
        required: true
        validEmail: true
      "green_order[routing_number]":
        required: true
        minlength: 9
        maxlength: 9
        number: true
      "green_order[address_zip]":
        required: true
        zipcode: true
      "green_order[account_number]":
        required: true
        number: true
    submitHandler: (form) ->
      $('form#new_green_order').find('input[type=submit]').prop 'disabled', true
      form.submit()
      return

  $('form#new_amg_order').validate
    rules:
      "amg_order[email_address]":
        required: true
        validEmail: true
      "amg_order[address_zip]":
        required: true
        zipcode: true
      "billing-cc-number":
        required: true
        creditcard: true
    submitHandler: (form) ->
      $('form#new_amg_order').find('input[type=submit]').prop 'disabled', true
      form.submit()
      return

  $('form#new_emb_order').validate
    rules:
      "emb_order[email_address]":
        required: true
        validEmail: true
      "emb_order[address_zip]":
        required: true
        zipcode: true
      "billing-cc-number":
        required: true
        creditcard: true
    submitHandler: (form) ->
      $('form#new_emb_order').find('input[type=submit]').prop 'disabled', true
      form.submit()
      return

  $('form.product_form_partial').validate
    rules:
      "product[videos_attributes][]":
        required: false
        filesize: 5

  (new Fingerprint2).get (result) ->
    $('#fly_buy_profile_fingerprint').val(result)
    return

  # $('form.create_fly_buy_profile').submit ->
  #   $(this).find(':submit').prop 'disabled', true
  #   $('*').css 'cursor', 'wait'
  #   return

  # $('.create_fly_buy_profile').ready ->
  #   if $('form.create_fly_buy_profile').is(':visible')
  #     evaluateMonthDates()
  #     return
  
  # $('.product_edit').ready ->
  #   if $('form.product_edit').is(':visible')
  #     evaluateInspectionDates()
  #     return

  # $('#product_inspection_date_attributes__date_1i').click ->
  #   evaluateInspectionDates()
  #   return
  $('.product_new').ready ->
    $('#product_inspection_date_attributes__date_1i').change ->
      month_select_block = $(this)[0].id
      month_select_box = $('#'+month_select_block)
      
      $(month_select_box).each ->
        endMonthSelected = $('#product_end_date_2i').val()
        endYearSelected = $('#product_end_date_1i').val()
        startYearSelected = $('#product_start_date_1i').val()
        yearSelectBlock = $(this)[0].id
        yearSelectBox = $('#'+yearSelectBlock)

        monthSelectBox = yearSelectBox.siblings('select#product_inspection_date_attributes__date_2i')

        monthSelectBox.html ''
        monthNames = [
          'January'
          'February'
          'March'
          'April'
          'May'
          'June'
          'July'
          'August'
          'September'
          'October'
          'November'
          'December'
        ]

        j = 0


        if yearSelectBox.val() == endYearSelected
          while j < parseInt(endMonthSelected) - 1
            month_count = j + 1
            monthSelectBox.append '<option value="' + month_count + '">' + monthNames[j] + '</option>'
            j++
          monthSelectBox.val(0)
          return
        else
          while j < 12
            month_count = j + 1
            monthSelectBox.append '<option value="' + month_count + '">' + monthNames[j] + '</option>'
            j++
          monthSelectBox.val(0)
          return
      return

  $('.product_edit').ready ->
    $('#product_inspection_date_attributes__date_1i').change ->
      month_select_block = $(this)[0].id
      month_select_box = $('#'+month_select_block)
      
      $(month_select_box).each ->
        inspection_date_value = $('#product_hidden_field_name').val()
        inspection_date_array = inspection_date_value.split("-")
        selectedYear = inspection_date_array[0]
        selectedMonth = inspection_date_array[1]
        selectedDay = inspection_date_array[2]

        endMonthSelected = $('#product_end_date_2i').val()
        endYearSelected = $('#product_end_date_1i').val()

        yearSelectBlock = $(this)[0].id
        yearSelectBox = $('#'+yearSelectBlock)

        monthSelectBox = yearSelectBox.siblings('select#product_inspection_date_attributes__date_2i')

        monthSelectBox.html ''
        monthNames = [
          'January'
          'February'
          'March'
          'April'
          'May'
          'June'
          'July'
          'August'
          'September'
          'October'
          'November'
          'December'
        ]

        j = 0
        if yearSelectBox.val() == endYearSelected
          while j < parseInt(endMonthSelected) - 1
            month_count = j + 1
            monthSelectBox.append '<option value="' + month_count + '">' + monthNames[j] + '</option>'
            j++
          monthSelectBox.val(parseInt(selectedMonth) - 1)
          if monthSelectBox.val() == null
            monthSelectBox.val(0)
          return
        else
          while j < 12
            month_count = j + 1
            monthSelectBox.append '<option value="' + month_count + '">' + monthNames[j] + '</option>'
            j++
          monthSelectBox.val(parseInt(selectedMonth))
          if monthSelectBox.val() == null
            monthSelectBox.val(0)
          return
      return

  evaluateInspectionDates = ->
    $('#product_end_date_2i').each ->
      selectedMonth = $('#product_inspection_date_attributes__date_2i').val()
      selectedYear = $('#product_inspection_date_attributes__date_1i').val()
      selectedDay = $('#product_inspection_date_attributes__date_3i').val()
      endMonthSelected = $('#product_end_date_2i').val()
      endYearSelected = $('#product_end_date_1i').val()
      monthSelect = $('#product_inspection_date_attributes__date_2i')
      daySelect = $('#product_inspection_date_attributes__date_3i')
      yearSelect = $('#product_inspection_date_attributes__date_1i')
      # year = parseInt(yearSelect.val())
      # month = parseInt(monthSelect.val())
      # days = new Date(year, month, 0).getDate()
      # selectedDay = daySelect.val()
      # selectedMonth = monthSelect.val()
      # daySelect.html ''
      # today = new Date
      # todayMonth = today.getMonth() + 1 #january is 0
      monthSelect.html ''
      monthNames = [
        'January'
        'February'
        'March'
        'April'
        'May'
        'June'
        'July'
        'August'
        'September'
        'October'
        'November'
        'December'
      ]
      j = 0
      if yearSelect.val() == endYearSelected
        while j < endMonthSelected - 1
          monthSelect.append '<option value="' + j + '">' + monthNames[j] + '</option>'
          j++
        daySelect.val(selectedDay)
        monthSelect.val(selectedMonth - 1)
        yearSelect.val(selectedYear)
        return
      else
        while j < 12
          month_count = j + 1
          monthSelect.append '<option value="' + month_count + '">' + monthNames[j] + '</option>'
          j++
        daySelect.val(selectedDay)
        monthSelect.val(selectedMonth)
        yearSelect.val(selectedYear)
        return
    return

  evaluateMonthDates = ->
    $('select[id*=_2i]').each ->
      monthSelect = $(this)
      daySelect = $(this).siblings('select[id*=_3i]')
      yearSelect = $(this).siblings('select[id*=_1i]')
      year = parseInt(yearSelect.val())
      month = parseInt(monthSelect.val())
      days = new Date(year, month, 0).getDate()
      selectedDay = daySelect.val()
      selectedMonth = monthSelect.val()
      daySelect.html ''
      today = new Date
      todayMonth = today.getMonth() + 1 #january is 0
      monthSelect.html ''
      monthNames = [
        'January'
        'February'
        'March'
        'April'
        'May'
        'June'
        'July'
        'August'
        'September'
        'October'
        'November'
        'December'
      ]
      i = 1
      while i <= days
        daySelect.append '<option value="' + i + '">' + i + '</option>'
        i++
      j = 1
      while j <= todayMonth
        monthSelect.append '<option value="' + j + '">' + monthNames[j - 1] + '</option>'
        j++
      daySelect.val selectedDay
      return
    return

  $('#product_default_payment').change ->
    if $('#product_default_payment').find(":selected").text() == "Fly And Buy"
      $('.insert_inspection_dates').show()
      endYearSelected = $('#product_end_date_1i').val()
      startYearSelected = $('#product_start_date_1i').val()

      yearSelectBox = $('#product_inspection_date_attributes__date_1i')

      yearSelectBox.html ''

      start_year = parseInt(startYearSelected)
      end_year = parseInt(endYearSelected)

      while start_year <= end_year
        yearSelectBox.append '<option value="' + start_year + '">' + start_year + '</option>'
        start_year++
      yearSelectBox.val
      return
    else
      $('.insert_inspection_dates').hide()

  $('form.edit_armor_profile').validate
    rules:
      "armor_profile[phone]":
        required: true
        remote:
          url: "/dashboard/accounts/check_valid_phone_number"
          type: "GET"
      "armor_profile[addresses][state]":
        required: true
        remote:
          url: "/dashboard/accounts/check_valid_state"
          type: "GET"
    messages:
      "armor_profile[phone]":
        remote: "Phone number is not valid."
      "armor_profile[addresses][state]":
        remote: "State is not valid. "
    errorPlacement: (error, element) ->
      # this is done for displaying the error message for agreed_terms checkbox
      # # below the checkbox
      if element.attr('name') == "armor_profile[agreed_terms]"
        error.insertAfter(element.parent().parent())
      else
        error.insertAfter element
      return

  $('form#new_promise_account').validate
    rules:
      "promise_account[bank_name]":
        required: true
      "promise_account[account_name]":
        required: true
      "promise_account[routing_number]":
        required: true
        minlength: 9
        maxlength: 9
        number: true
      "promise_account[account_number]":
        required: true
        minlength: 10
        maxlength: 10
        number: true
    errorPlacement: (error, element) ->
      # this is done for displaying the error message for DIRECT DEBIT AGREEMENT
      # # below the checkbox
      if element.attr('name') == "promise_account[direct_debit_agreement]"
        error.insertAfter(element.parent().parent())
      else
        error.insertAfter element
      return
    submitHandler: (form) ->
      $('form#new_promise_account').find('input[type=submit]').prop 'disabled', true
      $('*').css 'cursor', 'wait'
      form.submit()
      return

  $('form.create_fly_buy_profile').validate
    rules:
      "fly_buy_profile[company_email]":
        required: true
        email: true
      "fly_buy_profile[ssn_number]":
        maxlength: 10
        number: true
        required: true
      "fly_buy_profile[eic_attachment]":
        required: true,
        extension: "jpg|png|pdf"
      "fly_buy_profile[bank_statement]":
        required: true,
        extension: "jpg|png|pdf"
      "fly_buy_profile[gov_id]":
        required: true,
        extension: "jpg|png|pdf"
      "fly_buy_profile[dob(1i)]":
        check_date_of_birth: true
    messages:
      "fly_buy_profile[ssn_number]":
        remote: "Please enter no more than 10 digits."
      "fly_buy_profile[eic_attachment]":
        remote: "Only file extension jpg, jpeg and png is allowed. "
    errorPlacement: (error, element) ->
      # this is done for displaying the error message for DIRECT DEBIT AGREEMENT
      # # below the checkbox
      if element.attr('name') == "promise_account[direct_debit_agreement]"
        error.insertAfter(element.parent().parent())
      else
        error.insertAfter element
      return
    submitHandler: (form) ->
      $('form.create_fly_buy_profile').find('input[type=submit]').prop 'disabled', true
      $('*').css 'cursor', 'wait'
      form.submit()
      return

