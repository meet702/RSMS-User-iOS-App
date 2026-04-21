import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { amount, currency, receipt } = await req.json()
    console.log(`[Razorpay] Creating order for amount: ${amount} ${currency || 'INR'}`)
    
    const keyId = Deno.env.get('RAZORPAY_KEY_ID')
    const keySecret = Deno.env.get('RAZORPAY_KEY_SECRET')

    if (!keyId || !keySecret) {
      console.error('[Razorpay] ERROR: RAZORPAY_KEY_ID or RAZORPAY_KEY_SECRET is missing from Deno.env')
      throw new Error('Razorpay keys are not configured in Supabase secrets. Please run: supabase secrets set RAZORPAY_KEY_ID=... RAZORPAY_KEY_SECRET=...')
    }

    console.log(`[Razorpay] Using Key ID: ${keyId.substring(0, 8)}...`)

    // Razorpay expectations: Amount in smallest currency unit (paise for INR)
    const razorpayAmount = Math.round(amount * 100)
    console.log(`[Razorpay] Calculated amount in paise: ${razorpayAmount}`)

    const authHeader = 'Basic ' + btoa(`${keyId}:${keySecret}`)
    
    console.log(`[Razorpay] POSTing to https://api.razorpay.com/v1/orders`)
    const response = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
      },
      body: JSON.stringify({
        amount: razorpayAmount,
        currency: currency || 'INR',
        receipt: receipt || `receipt_${Date.now()}`,
      }),
    })

    const data = await response.json()
    console.log(`[Razorpay] Response status: ${response.status}`)

    if (!response.ok) {
      console.error('Razorpay API Error:', JSON.stringify(data))
      throw new Error(data.error?.description || `Razorpay API returned ${response.status}: ${JSON.stringify(data)}`)
    }

    return new Response(
      JSON.stringify({
        order_id: data.id,
        amount: data.amount,
        currency: data.currency
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
