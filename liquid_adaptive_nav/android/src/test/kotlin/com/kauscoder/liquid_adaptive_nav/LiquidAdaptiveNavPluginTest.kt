package com.kauscoder.liquid_adaptive_nav

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

internal class LiquidAdaptiveNavPluginTest {
    @Test
    fun onMethodCall_unknownMethod_callsNotImplemented() {
        val plugin = LiquidAdaptiveNavPlugin()
        val call = MethodCall("unknown", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }
}
