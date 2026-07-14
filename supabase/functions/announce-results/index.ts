// @ts-nocheck
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface Participant {
  doctorId: string
  doctorName: string
  onesignalPlayerId: string
  isWinner: boolean
  rank: number
}

interface RequestBody {
  announcementId: string
  announcementTitle: string
  participants: Participant[]
  topThreeNames: string[]
}

async function sendOneSignalNotification(
  playerId: string,
  title: string,
  message: string,
  data: Record<string, string>
): Promise<{ success: boolean; error?: string }> {
  try {
    const appId = Deno.env.get('ONESIGNAL_APP_ID')!
    const restKey = Deno.env.get('ONESIGNAL_REST_API_KEY')!

    const res = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${restKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        app_id: appId,
        include_player_ids: [playerId],
        headings: { en: title, ar: title },
        contents: { en: message, ar: message },
        data: data,
        priority: 10,
      }),
    })

    const result = await res.json()

    if (result.errors && result.errors.length > 0) {
      return { success: false, error: JSON.stringify(result.errors) }
    }

    return { success: true }
  } catch (error) {
    return { success: false, error: (error as Error).message }
  }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  try {
    const body: RequestBody = await req.json()
    const { announcementTitle, participants, topThreeNames, announcementId } = body

    if (!participants || participants.length === 0) {
      return new Response(JSON.stringify({ error: 'No participants' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    let successCount = 0
    let failCount = 0
    const errors: string[] = []

    for (const p of participants) {
      const bodyMessage = p.isWinner
        ? `🎉 مبروك! حصلت على المركز ${p.rank} في مسابقة "${announcementTitle}". اضغط لمشاهدة النتائج.`
        : `نأسف، لم تكن من الفائزين في مسابقة "${announcementTitle}". لا تيأس، فرص قادمة بانتظارك!`

      const dataPayload: Record<string, string> = {
        screen: 'competition_results',
        announcementId: announcementId,
        isWinner: p.isWinner.toString(),
        rank: p.rank.toString(),
        topThree: JSON.stringify(topThreeNames),
      }

      console.log(`📤 Sending to ${p.doctorName}...`)

      const result = await sendOneSignalNotification(
        p.onesignalPlayerId,
        '🏆 إعلان نتيجة المسابقة',
        bodyMessage,
        dataPayload
      )

      if (result.success) {
        successCount++
        console.log(`  ✅ ${p.doctorName}`)
      } else {
        failCount++
        errors.push(`[${p.doctorName}]: ${result.error}`)
        console.log(`  ❌ ${p.doctorName}: ${result.error}`)
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        totalParticipants: participants.length,
        successCount,
        failCount,
        errors: errors.length > 0 ? errors : undefined,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: (error as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})