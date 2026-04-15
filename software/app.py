import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import time
import os

# ====================================================================
# 1. PAGE CONFIGURATION
# ====================================================================
st.set_page_config(
    page_title="Edge-AI IoT Dashboard",
    page_icon="🔥",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# Custom CSS for glowing LED text and layout spacing
st.markdown("""
    <style>
    .big-font { font-size: 22px !important; font-weight: bold; text-align: center; }
    .safe-status { color: #00FF00; text-shadow: 0 0 10px #00FF00; }
    .warn-status { color: #FFA500; text-shadow: 0 0 10px #FFA500; }
    .fire-status { color: #FF0000; text-shadow: 0 0 10px #FF0000; }
    .flame-alert { color: #FF4500; font-weight: bold; font-size: 20px;}
    .flame-safe { color: #00FA9A; font-weight: bold; font-size: 20px;}
    </style>
""", unsafe_allow_html=True)

st.title("🔥 Real-Time Edge-AI Telemetry")
st.markdown("Live Neural Network Diagnostics | Nexys 4 FPGA Pipeline")
st.markdown("---")

# ====================================================================
# 2. DATA PROCESSING & UI RENDERING
# ====================================================================
if os.path.exists('sensor_data.csv'):
    try:
        # Read the live CSV file
        df = pd.read_csv('sensor_data.csv')
        
        if len(df) > 1:
            # Keep the last 60 seconds for the scrolling charts
            df = df.tail(60) 
            
            latest = df.iloc[-1]
            prev = df.iloc[-2]

            # ========================================================
            # 🚨 EMERGENCY OVERRIDE BANNER 🚨
            # ========================================================
            # If the IR sensor detects a flame, blast a massive warning
            # Note: Change '== 0' to '== 1' if your sensor works in reverse!
            if latest['Flame'] == 0:
                st.markdown("""
                    <div style="background-color: #4a0000; padding: 20px; border-radius: 10px; text-align: center; border: 3px solid #ff0000; margin-bottom: 25px; animation: blinker 1s linear infinite;">
                        <h1 style="color: #ff3333; margin: 0; text-shadow: 0 0 15px #ff0000;">🚨 CRITICAL HAZARD: ACTIVE FLAME DETECTED 🚨</h1>
                        <h4 style="color: white; margin: 0; padding-top: 5px;"> Immediate Evacuation Recommended.</h4>
                    </div>
                """, unsafe_allow_html=True)
            # ========================================================

            # --- TOP ROW: VITAL METRICS ---
            col1, col2, col3, col4, col5, col6 = st.columns(6)
            
            col1.metric("Temperature", f"{latest['Temp']} °C", f"{latest['Temp'] - prev['Temp']:.1f} °C")
            col2.metric("Humidity", f"{latest['Humidity']} %", f"{latest['Humidity'] - prev['Humidity']:.1f} %")
            col3.metric("Smoke (MQ2)", int(latest['MQ2']), int(latest['MQ2'] - prev['MQ2']))
            col4.metric("Gas (MQ135)", int(latest['MQ135']), int(latest['MQ135'] - prev['MQ135']))
            
            # --- THE FLAME SENSOR METER ---
            with col5:
                st.write("**IR Flame Sensor**")
                if latest['Flame'] == 0: 
                    st.markdown('<p class="flame-alert">⚠️ FLAME DETECTED</p>', unsafe_allow_html=True)
                else:
                    st.markdown('<p class="flame-safe">✅ Clear</p>', unsafe_allow_html=True)

            # --- NEURAL NETWORK STATUS ---
            with col6:
                status = latest['AI_Status']
                st.write("**FPGA Output**")
                # If there is a flame, force the AI status block to show FIRE too
                if latest['Flame'] == 0 or status != "SAFE":
                    st.markdown('<p class="big-font fire-status">🔴 FIRE / HAZARD</p>', unsafe_allow_html=True)
                else:
                    st.markdown('<p class="big-font safe-status">🟢 SAFE</p>', unsafe_allow_html=True)

            st.markdown("<br>", unsafe_allow_html=True) # Spacer

            # --- MIDDLE ROW: CHARTS ---
            chart_col1, chart_col2, chart_col3 = st.columns([1, 1, 1])
            
            # 1. Environment Line Chart
            with chart_col1:
                fig_env = px.line(df, x="Timestamp", y=["Temp", "Humidity"], 
                                  title="Environment History",
                                  template="plotly_dark",
                                  color_discrete_sequence=['#ff7f0e', '#00BFFF'])
                fig_env.update_layout(margin=dict(l=20, r=20, t=40, b=20), height=300)
                st.plotly_chart(fig_env, use_container_width=True)

            # 2. Gas Levels Line Chart
            with chart_col2:
                fig_gas = px.line(df, x="Timestamp", y=["MQ2", "MQ135"], 
                                  title="Hazardous Gas Tracking",
                                  template="plotly_dark",
                                  color_discrete_sequence=['#A9A9A9', '#8A2BE2'])
                fig_gas.update_layout(margin=dict(l=20, r=20, t=40, b=20), height=300)
                st.plotly_chart(fig_gas, use_container_width=True)

            # 3. Industrial Gauge for MQ135 (Air Quality)
            with chart_col3:
                fig_gauge = go.Figure(go.Indicator(
                    mode = "gauge+number",
                    value = latest['MQ135'],
                    domain = {'x': [0, 1], 'y': [0, 1]},
                    title = {'text': "Air Toxins (MQ135)", 'font': {'size': 18}},
                    gauge = {
                        'axis': {'range': [0, 255], 'tickwidth': 1, 'tickcolor': "white"},
                        'bar': {'color': "rgba(0,0,0,0)"},
                        'bgcolor': "black",
                        'borderwidth': 2,
                        'bordercolor': "gray",
                        'steps': [
                            {'range': [0, 80], 'color': "green"},
                            {'range': [80, 150], 'color': "orange"},
                            {'range': [150, 255], 'color': "red"}],
                        'threshold': {
                            'line': {'color': "white", 'width': 4},
                            'thickness': 0.75,
                            'value': latest['MQ135']}
                    }
                ))
                fig_gauge.update_layout(template="plotly_dark", margin=dict(l=20, r=20, t=40, b=20), height=300)
                st.plotly_chart(fig_gauge, use_container_width=True)

    except Exception as e:
        pass 
else:
    st.warning("Waiting for sensor data... Please ensure logger.py is running!")

# ====================================================================
# 3. THE REFRESH ENGINE
# ====================================================================
time.sleep(1)
st.rerun()