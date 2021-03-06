App.registerBehavior 'EstimateShipping'

class Behavior.EstimateShipping
  constructor: ($el) ->
    @$shippingEstimateCost =  $el.data 'cost'
    @$shippingEstimateType =  $el.data 'type'
    @$shippingEstimate     =  $ '.calc-shipping'
    @$calculationPanel     =  $ '.vp-calculation, .vp-calculation-checkout'

    @options        = @$calculationPanel.data 'options'
    @$cart          = @$calculationPanel.find '.calc-cart'
    @$quantity      = @$calculationPanel.find '.calc-quantity'
    @$rebate        = @$calculationPanel.find '.calc-rebate'
    @$pcs           = @$calculationPanel.find '.calc-pcs'
    @$rebPrice      = @$calculationPanel.find '.calc-rebate-price'
    @$feePrice      = @$calculationPanel.find '.calc-fees-price'
    @$shippingPrice = @$calculationPanel.find '.calc-shipping-price'

    @fees       = parseFloat @$calculationPanel.find('.calc-fees').text(), 10
    @unitPrice  = @$calculationPanel.find('[data-unit-price]').data 'unit-price'

    @$stripeQuantity      = $ '.stripe-quantity'
    @$stripeTotal         = $ '.stripe-total'
    @$stripeUnitTotal     = $ '.stripe-unit-total'
    @$stripeRebate        = $ '.stripe-rebate'
    @$stripeFees          = $ '.stripe-fees-price'
    @$stripeShipping      = $ '.stripe-shipping'
    @$stripeShippingPrice = $ '.stripe-shipping-price'
    @$stripeRabetePrice   = $ '.stripe-rabete-price'
    @$stripeButtonScript  = $ '.stripe-button'
    @$stripeButton        = $ '.stripe-button-el'

    @$stripeAmount        = $ '[name="stripe_order[total]"], [name="green_order[total]"], [name="armor_order[total]"], [name="amg_order[total]"], [name="emb_order[total]"]'
    @$stripeCount         = $ '[name="stripe_order[count]"], [name="green_order[count]"], [name="armor_order[count]"], [name="amg_order[count]"], [name="emb_order[count]"]'
    @$stripeFeesPrice     = $ '[name="stripe_order[fee]"], [name="green_order[fee]"], [name="armor_order[fee]"], [name="amg_order[fee]"], [name="emb_order[fee]"]'
    @$stripeShippingCost  = $ '[name="stripe_order[shipping_cost]"], [name="green_order[shipping_cost]"], [name="armor_order[shipping_cost]"], [name="amg_order[shipping_cost]"], [name="emb_order[shipping_cost]"]'
    @$stripeRebatePrice   = $ '[name="stripe_order[rebate]"], [name="green_order[rebate]"], [name="armor_order[rebate]"], [name="amg_order[rebate]"], [name="emb_order[rebate]"]'
    @$stripeRebatePercent = $ '[name="stripe_order[rebate_percent]"], [name="green_order[rebate_percent]"], [name="armor_order[rebate_percent]"], [name="amg_order[rebate_percent]"], [name="emb_order[rebate_percent]"]'

    @$footer = $ '.payment-button'

    @$checkout = $ '.checkout'

    $el.click => do @updateShippingEstimate

  updateShippingEstimate: =>
    @$shippingEstimate.text @$shippingEstimateCost
    @$shippingEstimate.data 'type', @$shippingEstimateType
    @calculation()
    return true

  fixed: (number) =>
    number.toFixed(2).toString()

  number_to_currency: (amount) =>
    amount.replace /(\d)(?=(\d{3})+(?!\d))/g, "$1,"

  calculation: =>
    total  = 0
    rebate = 0
    quantity = parseInt @$quantity.val(), 10
    quantity = 1 unless quantity

    if quantity <= @options.maxquantity
      if @options.pricebreaks.length > 0
        for pricebreak, i in @options.pricebreaks
          prevQuantity = if i > 0 then @options.pricebreaks[i-1].quantity else 0

          if i is 0
            total  = quantity * @unitPrice

          else if prevQuantity < quantity <= pricebreak.quantity
            total  = quantity * @options.pricebreaks[i-1].price
            rebate = quantity * (@unitPrice - @options.pricebreaks[i-1].price)

        lastPricebreak = @options.pricebreaks[@options.pricebreaks.length-1]

        if lastPricebreak.quantity < quantity <= @options.maxquantity
          total  = quantity * lastPricebreak.price
          rebate = quantity * (@unitPrice - lastPricebreak.price)

      else
        total = quantity * @unitPrice

    total = quantity * @unitPrice

    fees              = total * (@fees || 0) / 100
    if @$shippingEstimateType == 'PerUnit'
      shipping_per_unit = parseFloat @$shippingEstimateCost
      shipping_cost     = shipping_per_unit * quantity
    else
      if @$shippingEstimateType == 'FlatRate'
        shipping_cost = parseFloat @$shippingEstimateCost
      else
        shipping_cost = 0
    rebatep           = (rebate * 100) / (@unitPrice * quantity)
    cart              = total + fees + shipping_cost - rebate

    if total > 1
      @$checkout.removeClass 'disabled'
    else
      @$checkout.addClass 'disabled'

    if shipping_cost > 0
      @$footer.show()
    else
      @$footer.hide()


    @$rebate.text @number_to_currency(@fixed rebatep)
    @$pcs.text quantity
    @$feePrice.text @number_to_currency(@fixed fees)
    @$shippingPrice.text @number_to_currency(@fixed shipping_cost)
    @$rebPrice.text @number_to_currency(@fixed rebate)
    @$cart.text @number_to_currency(@fixed cart)

    @$stripeQuantity.text quantity
    @$stripeTotal.text @number_to_currency(@fixed cart)
    @$stripeUnitTotal.text @number_to_currency(@fixed @unitPrice * quantity)
    @$stripeRebate.text @number_to_currency(@fixed rebatep)
    @$stripeFees.text @number_to_currency(@fixed fees)
    @$stripeShipping.text @number_to_currency(@fixed parseFloat @$shippingEstimate.text(), 2)
    @$stripeShippingPrice.text @number_to_currency(@fixed shipping_cost)
    @$stripeRabetePrice.text @number_to_currency(@fixed rebate)

    @$stripeAmount.val cart.toFixed 2
    @$stripeCount.val quantity
    @$stripeFeesPrice.val fees.toFixed 2
    @$stripeShippingCost.val shipping_cost.toFixed 2
    @$stripeRebatePrice.val rebate.toFixed 2
    @$stripeRebatePercent.val rebatep.toFixed 2

    @$stripeButtonScript.attr 'data-amount', cart.toFixed 2
    @$stripeButton.disabled = false
