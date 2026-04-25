local TipProductConfig = {}

-- Shared tip product mapping used by both the purchase prompt and receipt handler.
TipProductConfig.ButtonProductIds = {
	tipframe5 = 5728165,
	tipframe10 = 5728167,
	tipframe100 = 5728183,
	tipframe1000 = 5734568,
	tipframe10000 = 5728180,
}

TipProductConfig.ProductAmounts = {
	[5728165] = 5,
	[5728167] = 10,
	[5728183] = 100,
	[5734568] = 1000,
	[5728180] = 10000,
}

function TipProductConfig.getProductIdForButton(buttonName)
	return TipProductConfig.ButtonProductIds[buttonName]
end

function TipProductConfig.getAmountForProduct(productId)
	return TipProductConfig.ProductAmounts[productId]
end

return TipProductConfig
