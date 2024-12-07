classdef main < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        Lamp                            matlab.ui.control.Lamp
        StopButton                      matlab.ui.control.Button
        RecordingButton                 matlab.ui.control.Button
        StopButton_3                    matlab.ui.control.Button
        StopButton_2                    matlab.ui.control.Button
        PlayButton_2                    matlab.ui.control.Button
        PlayButton                      matlab.ui.control.Button
        TakethefileasinputButton        matlab.ui.control.Button
        SavetheprocessedsequenceButton  matlab.ui.control.Button
        TheprocessedsequenceisusedasthenewinputButton  matlab.ui.control.Button
        TabGroup                        matlab.ui.container.TabGroup
        AddNoiseTab                     matlab.ui.container.Tab
        FrequencyHzLabel                matlab.ui.control.Label
        EditField2                      matlab.ui.control.NumericEditField
        ProcessandAnalyseButton         matlab.ui.control.Button
        NoiseDistributionDropDown       matlab.ui.control.DropDown
        Label_2                         matlab.ui.control.Label
        NoiseGainSlider                 matlab.ui.control.Slider
        Label                           matlab.ui.control.Label
        FilterTab                       matlab.ui.container.Tab
        ProcessandAnalyseButton_2       matlab.ui.control.Button
        UpperFreqLimitLabel             matlab.ui.control.Label
        EditField4                      matlab.ui.control.NumericEditField
        LowerFreqLimitLabel             matlab.ui.control.Label
        EditField3                      matlab.ui.control.NumericEditField
        TypeDropDown                    matlab.ui.control.DropDown
        Label_9                         matlab.ui.control.Label
        OrderEditField                  matlab.ui.control.NumericEditField
        Label_8                         matlab.ui.control.Label
        WindowFunctionDropDown          matlab.ui.control.DropDown
        Label_7                         matlab.ui.control.Label
        NoiseSuppressionTab             matlab.ui.container.Tab
        FrameDurationEditField          matlab.ui.control.EditField
        FrameDurationEditFieldLabel     matlab.ui.control.Label
        VADThresholdEditField           matlab.ui.control.EditField
        VADThresholdEditFieldLabel      matlab.ui.control.Label
        SmoothFactorEditField           matlab.ui.control.EditField
        SmoothFactorEditFieldLabel      matlab.ui.control.Label
        ProcessandAnalyseButton_3       matlab.ui.control.Button
        ReverberationTab                matlab.ui.container.Tab
        Reverb_DelaySlider              matlab.ui.control.Slider
        Label_4                         matlab.ui.control.Label
        Reverb_GainSlider               matlab.ui.control.Slider
        Label_3                         matlab.ui.control.Label
        ProcessandAnalyseButton_4       matlab.ui.control.Button
        VoiceChangingTab                matlab.ui.container.Tab
        SpeedModificationSlider         matlab.ui.control.Slider
        SpeedModificationSliderLabel    matlab.ui.control.Label
        FundamentalFrequencyCoefficientSlider  matlab.ui.control.Slider
        Label_12                        matlab.ui.control.Label
        ProcessandAnalyseButton_5       matlab.ui.control.Button
        FilePathEditField               matlab.ui.control.EditField
        Label_5                         matlab.ui.control.Label
        SelectButton                    matlab.ui.control.Button
        VisualAnalysisButtonGroup       matlab.ui.container.ButtonGroup
        TimeDomainButton                matlab.ui.control.ToggleButton
        FrequencyDomainButton           matlab.ui.control.ToggleButton
        UIAxes_3                        matlab.ui.control.UIAxes
        UIAxes_2                        matlab.ui.control.UIAxes
    end

    
    properties (Access = private)

    end
    
    properties (Access = public)
%         Property2 % Description

        file="ttsmaker-file-2023-12-23-20-30-29.mp3";
        folder="D:\workplace\matlab\dsp_integrate_experiment\";
        y1;
        fs1;
        y2;

        ffty1;

        ffty2;

        recObj = audiorecorder;
    end
    
    methods (Access = private)
        
        function to_one(app)
            app.y1 = sum(app.y1,2)/2;
        end
        
        function [f, mag] = seq2f2mag(~,x,Fs)
            % 读取音频文件
            % 计算FFT并获取幅度谱
            N = length(x);
            n = pow2(nextpow2(N));  % transform length
            X = fft(x,n);
%             mag = 20*log10(abs(X(1:n/2+1)));
            mag = abs(X(1:n/2+1)).^2/n;
            % 创建频率向量
            f = Fs*(0:(n/2))/n;
        end
        
        function draw_output(app)
            if app.TimeDomainButton.Value
                plot(app.UIAxes_2, linspace(0,(length(app.y2)/app.fs1),length(app.y2)), app.y2 )
                xlabel(app.UIAxes_2, 't/s')
                ylabel(app.UIAxes_2, 'Amp.')
            elseif app.FrequencyDomainButton.Value
                [f,mag]=app.seq2f2mag(app.y2,app.fs1);
                plot(app.UIAxes_2, f,mag)
                xlabel(app.UIAxes_2, 'f/Hz')
                ylabel(app.UIAxes_2, 'Mag.')
            end
        end
        
        function draw_input(app)
            if app.TimeDomainButton.Value
                plot(app.UIAxes_3, linspace(0,(length(app.y1)/app.fs1),length(app.y1)), app.y1 )
                xlabel(app.UIAxes_3, 't/s')
                ylabel(app.UIAxes_3, 'Amp.')
            elseif app.FrequencyDomainButton.Value
                [f,mag]=app.seq2f2mag(app.y1,app.fs1);
                plot(app.UIAxes_3, f ,mag )
                xlabel(app.UIAxes_3, 'f/Hz')
                ylabel(app.UIAxes_3, 'Mag.')
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: SelectButton
        function SelectButtonPushed(app, event)
            try
                [app.file,app.folder]=uigetfile('*.mp3;*.wav;*.m4a');
                app.FilePathEditField.Value=strcat(app.folder,app.file);
            catch 
                fprintf("Unselected")
            end

        end

        % Button pushed function: TakethefileasinputButton
        function TakethefileasinputButtonPushed(app, event)
            try
                [app.y1,app.fs1]=audioread(strcat(app.folder,app.file));
                app.to_one()
                app.draw_input()
            catch e
                e
                warndlg("Invalid input")
            end
        end

        % Button pushed function: ProcessandAnalyseButton
        function ProcessandAnalyseButtonPushed(app, event)
            try
                cata=app.NoiseDistributionDropDown.Value;    
                if cata=="Mean"
                    app.y2=rand(length(app.y1),1)*2*app.NoiseGainSlider.Value*max(app.y1)+app.y1;
                elseif cata=="高斯"
                    app.y2=randn(length(app.y1),1)*app.NoiseGainSlider.Value*max(app.y1)+app.y1;
                elseif cata=="正弦"
                    f=app.EditField2.Value;
                    app.y2=cos(2*pi*f*(1:length(app.y1))/app.fs1)'*app.NoiseGainSlider.Value*max(app.y1)+app.y1;
%                 else
%                     warndlg("未处理")
%                     return
                end
                
                app.draw_output();
               
            catch e
                e
                warndlg("未处理")
            end
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            if ~isempty(app.y1)
                sound(app.y1,app.fs1)
            end
        end

        % Value changed function: NoiseDistributionDropDown
        function NoiseDistributionDropDownValueChanged(app, event)
            value = app.NoiseDistributionDropDown.Value;
            if value=="正弦"
                app.EditField2.Enable=1;
            else
                app.EditField2.Enable=0;
            end
        end

        % Selection changed function: VisualAnalysisButtonGroup
        function VisualAnalysisButtonGroupSelectionChanged(app, event)
            if ~isempty(app.y1)
                app.draw_input()
            end

            if ~isempty(app.y2)
                app.draw_output()
            end

        end

        % Button pushed function: 
        % TheprocessedsequenceisusedasthenewinputButton
        function TheprocessedsequenceisusedasthenewinputButtonPushed(app, event)
            if ~isempty(app.y2)
                app.y1=app.y2;
                app.draw_input()
            end
        end

        % Button pushed function: ProcessandAnalyseButton_4
        function ProcessandAnalyseButton_4Pushed(app, event)
            if isempty(app.y1)
                return
            end
            if size(app.y1,1)<size(app.y1,2)
                app.y1=app.y1';
            end
            app.y2=[zeros(floor(app.Reverb_DelaySlider.Value*app.fs1),1);app.Reverb_GainSlider.Value.*app.y1]+...
                    [app.y1;zeros(floor(app.Reverb_DelaySlider.Value*app.fs1),1)];
            app.y2=app.y2(1:length(app.y1));
            app.draw_output();
        end

        % Button pushed function: PlayButton_2
        function PlayButton_2Pushed(app, event)
            if ~isempty(app.y2)
                sound(app.y2,app.fs1)
            end
        end

        % Button pushed function: StopButton_2
        function StopButton_2Pushed(app, event)
            clear sound
        end

        % Button pushed function: StopButton_3
        function StopButton_3Pushed(app, event)
            clear sound
        end

        % Button pushed function: RecordingButton
        function RecordingButtonPushed(app, event)
            record(app.recObj);
            disp('Recording in progress now ...')
            app.Lamp.Color='r';
        end

        % Button pushed function: ProcessandAnalyseButton_2
        function ProcessandAnalyseButton_2Pushed(app, event)
            try
                windowname=app.WindowFunctionDropDown.Value;
                cata=app.TypeDropDown.Value;
                n=app.EditField2.Value;

                if windowname=="海明"
                    window=hamming(n+1);
                elseif windowname=="布莱克曼"
                    window=blackman(n+1);
                elseif windowname=="矩形"
                    window=ones(1,n+1);
                end

%                 user_filter=fir1()
                if cata=="高通"
                    ll=app.EditField3.Value/app.fs1*2;
                    user_filter=fir1(n,ll,"high",window);
                    app.y2=filter(user_filter,1,app.y1);

                elseif cata=="低通"
                    ul=app.EditField4.Value/app.fs1*2;
                    user_filter=fir1(n,ul,"low",window);
                    app.y2=filter(user_filter,1,app.y1);

                elseif cata=="带通"
                    ul=app.EditField4.Value/app.fs1*2;
                    ll=app.EditField3.Value/app.fs1*2;
                    user_filter=fir1(n,[ll ul],"bandpass",window);
                    app.y2=filter(user_filter,1,app.y1);

                elseif cata=="带阻"
                    ul=app.EditField4.Value/app.fs1*2;
                    ll=app.EditField3.Value/app.fs1*2;
                    user_filter=fir1(n,[ll ul],"stop",window);
                    app.y2=filter(user_filter,1,app.y1);

                else
                    warndlg("未处理")
                    return
                end
                
                app.draw_output();
               
            catch e
                e
                warndlg("未处理")
            end
        end

        % Value changed function: TypeDropDown
        function TypeDropDownValueChanged(app, event)
            cata = app.TypeDropDown.Value;

            if cata=="高通"
                app.EditField3.Enable=1;
                app.EditField4.Enable=0;
            elseif cata=="低通"
                app.EditField3.Enable=0;
                app.EditField4.Enable=1;

            elseif cata=="带通"
                app.EditField3.Enable=1;
                app.EditField4.Enable=1;

            elseif cata=="带阻"
                app.EditField3.Enable=1;
                app.EditField4.Enable=1;

            else
                warndlg("未处理")
                return
            end
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            try
                stop(app.recObj)
                app.y1=getaudiodata(app.recObj);
                app.fs1=8000;
                app.draw_input()
                app.Lamp.Color='black';
            catch e
                e
            end
        end

        % Button pushed function: ProcessandAnalyseButton_5
        function ProcessandAnalyseButton_5Pushed(app, event)
            try
                slidernum=app.FundamentalFrequencyCoefficientSlider.Value;
                if slidernum<0
                    alpha=-5*slidernum;
                elseif slidernum>0
                    alpha=1/(1+5*slidernum);
                else
                    alpha=1;
                end

                app.y2=voice(app.y1,alpha);
                [q,p]=rat(app.SpeedModificationSlider.Value);
                app.y2=resample(app.y2,p,q);
                app.draw_output()
            catch e
                e
            end
        end

        % Button pushed function: SavetheprocessedsequenceButton
        function SavetheprocessedsequenceButtonPushed(app, event)
            try
                audiowrite(strcat("-1-",app.file,".wav"),app.y2,app.fs1)
            catch e
                e
            end
        end

        % Button pushed function: ProcessandAnalyseButton_3
        function ProcessandAnalyseButton_3Pushed(app, event)
            try
                if size(app.y1,1)<size(app.y1,2)
                    app.y1=app.y1';
                end
                mu=str2double(app.SmoothFactorEditField.Value);
                eta=str2double(app.VADThresholdEditField.Value);
                fr=str2double(app.FrameDurationEditField.Value);
                app.y2=wiener_as(app.y1,app.fs1,mu,eta,fr);
                app.draw_output()
            catch e
                e
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1072 716];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'After Processing')
            xlabel(app.UIAxes_2, 'X')
            ylabel(app.UIAxes_2, 'Y')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.Position = [611 72 394 233];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.UIFigure);
            title(app.UIAxes_3, 'Before Processing')
            xlabel(app.UIAxes_3, 'X')
            ylabel(app.UIAxes_3, 'Y')
            zlabel(app.UIAxes_3, 'Z')
            app.UIAxes_3.Position = [612 350 394 233];

            % Create VisualAnalysisButtonGroup
            app.VisualAnalysisButtonGroup = uibuttongroup(app.UIFigure);
            app.VisualAnalysisButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @VisualAnalysisButtonGroupSelectionChanged, true);
            app.VisualAnalysisButtonGroup.Title = 'Visual Analysis';
            app.VisualAnalysisButtonGroup.Position = [651 605 278 65];

            % Create FrequencyDomainButton
            app.FrequencyDomainButton = uitogglebutton(app.VisualAnalysisButtonGroup);
            app.FrequencyDomainButton.Text = 'Frequency Domain';
            app.FrequencyDomainButton.Position = [146 8 116 24];
            app.FrequencyDomainButton.Value = true;

            % Create TimeDomainButton
            app.TimeDomainButton = uitogglebutton(app.VisualAnalysisButtonGroup);
            app.TimeDomainButton.Text = 'Time Domain';
            app.TimeDomainButton.Position = [27 8 100 24];

            % Create SelectButton
            app.SelectButton = uibutton(app.UIFigure, 'push');
            app.SelectButton.ButtonPushedFcn = createCallbackFcn(app, @SelectButtonPushed, true);
            app.SelectButton.Position = [376 631 90 24];
            app.SelectButton.Text = 'Select';

            % Create Label_5
            app.Label_5 = uilabel(app.UIFigure);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.Position = [50 632 52 22];
            app.Label_5.Text = 'File Path';

            % Create FilePathEditField
            app.FilePathEditField = uieditfield(app.UIFigure, 'text');
            app.FilePathEditField.Position = [117 632 236 22];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [44 176 553 371];

            % Create AddNoiseTab
            app.AddNoiseTab = uitab(app.TabGroup);
            app.AddNoiseTab.Title = 'Add Noise';

            % Create Label
            app.Label = uilabel(app.AddNoiseTab);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [37 288 64 22];
            app.Label.Text = 'Noise Gain';

            % Create NoiseGainSlider
            app.NoiseGainSlider = uislider(app.AddNoiseTab);
            app.NoiseGainSlider.Limits = [0 0.4];
            app.NoiseGainSlider.Position = [131 306 277 3];

            % Create Label_2
            app.Label_2 = uilabel(app.AddNoiseTab);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [2 230 99 22];
            app.Label_2.Text = 'Noise Distribution';

            % Create NoiseDistributionDropDown
            app.NoiseDistributionDropDown = uidropdown(app.AddNoiseTab);
            app.NoiseDistributionDropDown.Items = {'Mean', 'Gaussian', 'Sine'};
            app.NoiseDistributionDropDown.ValueChangedFcn = createCallbackFcn(app, @NoiseDistributionDropDownValueChanged, true);
            app.NoiseDistributionDropDown.Position = [125 229 100 22];
            app.NoiseDistributionDropDown.Value = 'Mean';

            % Create ProcessandAnalyseButton
            app.ProcessandAnalyseButton = uibutton(app.AddNoiseTab, 'push');
            app.ProcessandAnalyseButton.ButtonPushedFcn = createCallbackFcn(app, @ProcessandAnalyseButtonPushed, true);
            app.ProcessandAnalyseButton.Position = [415 15 127 24];
            app.ProcessandAnalyseButton.Text = 'Process and Analyse';

            % Create EditField2
            app.EditField2 = uieditfield(app.AddNoiseTab, 'numeric');
            app.EditField2.Limits = [0 20000];
            app.EditField2.Enable = 'off';
            app.EditField2.Position = [123 169 100 22];
            app.EditField2.Value = 1800;

            % Create FrequencyHzLabel
            app.FrequencyHzLabel = uilabel(app.AddNoiseTab);
            app.FrequencyHzLabel.HorizontalAlignment = 'right';
            app.FrequencyHzLabel.Position = [17 169 84 22];
            app.FrequencyHzLabel.Text = 'Frequency(Hz)';

            % Create FilterTab
            app.FilterTab = uitab(app.TabGroup);
            app.FilterTab.Title = 'Filter';

            % Create Label_7
            app.Label_7 = uilabel(app.FilterTab);
            app.Label_7.HorizontalAlignment = 'right';
            app.Label_7.Position = [10 297 97 22];
            app.Label_7.Text = 'Window Function';

            % Create WindowFunctionDropDown
            app.WindowFunctionDropDown = uidropdown(app.FilterTab);
            app.WindowFunctionDropDown.Items = {'Hamming', 'Blackman', 'Rectangular'};
            app.WindowFunctionDropDown.Position = [139 297 128 22];
            app.WindowFunctionDropDown.Value = 'Hamming';

            % Create Label_8
            app.Label_8 = uilabel(app.FilterTab);
            app.Label_8.HorizontalAlignment = 'right';
            app.Label_8.Position = [74 250 36 22];
            app.Label_8.Text = 'Order';

            % Create OrderEditField
            app.OrderEditField = uieditfield(app.FilterTab, 'numeric');
            app.OrderEditField.Position = [139 253 128 22];
            app.OrderEditField.Value = 48;

            % Create Label_9
            app.Label_9 = uilabel(app.FilterTab);
            app.Label_9.HorizontalAlignment = 'right';
            app.Label_9.Position = [74 202 31 22];
            app.Label_9.Text = 'Type';

            % Create TypeDropDown
            app.TypeDropDown = uidropdown(app.FilterTab);
            app.TypeDropDown.Items = {'Highpass', 'Lowpass', 'Bandpass', 'Bandstop'};
            app.TypeDropDown.ValueChangedFcn = createCallbackFcn(app, @TypeDropDownValueChanged, true);
            app.TypeDropDown.Position = [139 202 128 22];
            app.TypeDropDown.Value = 'Highpass';

            % Create EditField3
            app.EditField3 = uieditfield(app.FilterTab, 'numeric');
            app.EditField3.Limits = [0 10000];
            app.EditField3.Position = [139 150 127 22];
            app.EditField3.Value = 20;

            % Create LowerFreqLimitLabel
            app.LowerFreqLimitLabel = uilabel(app.FilterTab);
            app.LowerFreqLimitLabel.HorizontalAlignment = 'right';
            app.LowerFreqLimitLabel.Position = [19 150 98 22];
            app.LowerFreqLimitLabel.Text = 'Lower Freq. Limit';

            % Create EditField4
            app.EditField4 = uieditfield(app.FilterTab, 'numeric');
            app.EditField4.Limits = [0 50000];
            app.EditField4.Position = [139 98 127 22];
            app.EditField4.Value = 5000;

            % Create UpperFreqLimitLabel
            app.UpperFreqLimitLabel = uilabel(app.FilterTab);
            app.UpperFreqLimitLabel.HorizontalAlignment = 'right';
            app.UpperFreqLimitLabel.Position = [19 98 98 22];
            app.UpperFreqLimitLabel.Text = 'Upper Freq. Limit';

            % Create ProcessandAnalyseButton_2
            app.ProcessandAnalyseButton_2 = uibutton(app.FilterTab, 'push');
            app.ProcessandAnalyseButton_2.ButtonPushedFcn = createCallbackFcn(app, @ProcessandAnalyseButton_2Pushed, true);
            app.ProcessandAnalyseButton_2.Position = [415 15 127 24];
            app.ProcessandAnalyseButton_2.Text = 'Process and Analyse';

            % Create NoiseSuppressionTab
            app.NoiseSuppressionTab = uitab(app.TabGroup);
            app.NoiseSuppressionTab.Title = 'Noise Suppression';

            % Create ProcessandAnalyseButton_3
            app.ProcessandAnalyseButton_3 = uibutton(app.NoiseSuppressionTab, 'push');
            app.ProcessandAnalyseButton_3.ButtonPushedFcn = createCallbackFcn(app, @ProcessandAnalyseButton_3Pushed, true);
            app.ProcessandAnalyseButton_3.Position = [415 15 127 24];
            app.ProcessandAnalyseButton_3.Text = 'Process and Analyse';

            % Create SmoothFactorEditFieldLabel
            app.SmoothFactorEditFieldLabel = uilabel(app.NoiseSuppressionTab);
            app.SmoothFactorEditFieldLabel.HorizontalAlignment = 'right';
            app.SmoothFactorEditFieldLabel.Position = [31 288 98 22];
            app.SmoothFactorEditFieldLabel.Text = 'Smooth Factor(μ)';

            % Create SmoothFactorEditField
            app.SmoothFactorEditField = uieditfield(app.NoiseSuppressionTab, 'text');
            app.SmoothFactorEditField.Position = [170 288 100 22];
            app.SmoothFactorEditField.Value = '0.98';

            % Create VADThresholdEditFieldLabel
            app.VADThresholdEditFieldLabel = uilabel(app.NoiseSuppressionTab);
            app.VADThresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.VADThresholdEditFieldLabel.Position = [29 233 100 22];
            app.VADThresholdEditFieldLabel.Text = 'VAD Threshold(η)';

            % Create VADThresholdEditField
            app.VADThresholdEditField = uieditfield(app.NoiseSuppressionTab, 'text');
            app.VADThresholdEditField.Position = [170 233 100 22];
            app.VADThresholdEditField.Value = '0.15';

            % Create FrameDurationEditFieldLabel
            app.FrameDurationEditFieldLabel = uilabel(app.NoiseSuppressionTab);
            app.FrameDurationEditFieldLabel.HorizontalAlignment = 'right';
            app.FrameDurationEditFieldLabel.Position = [35 181 88 22];
            app.FrameDurationEditFieldLabel.Text = 'Frame Duration';

            % Create FrameDurationEditField
            app.FrameDurationEditField = uieditfield(app.NoiseSuppressionTab, 'text');
            app.FrameDurationEditField.Position = [170 181 100 22];
            app.FrameDurationEditField.Value = '20';

            % Create ReverberationTab
            app.ReverberationTab = uitab(app.TabGroup);
            app.ReverberationTab.Title = 'Reverberation';

            % Create ProcessandAnalyseButton_4
            app.ProcessandAnalyseButton_4 = uibutton(app.ReverberationTab, 'push');
            app.ProcessandAnalyseButton_4.ButtonPushedFcn = createCallbackFcn(app, @ProcessandAnalyseButton_4Pushed, true);
            app.ProcessandAnalyseButton_4.Position = [415 15 127 24];
            app.ProcessandAnalyseButton_4.Text = 'Process and Analyse';

            % Create Label_3
            app.Label_3 = uilabel(app.ReverberationTab);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Position = [19 298 76 22];
            app.Label_3.Text = 'Reverb_Gain';

            % Create Reverb_GainSlider
            app.Reverb_GainSlider = uislider(app.ReverberationTab);
            app.Reverb_GainSlider.Limits = [0 1];
            app.Reverb_GainSlider.Position = [116 307 256 3];
            app.Reverb_GainSlider.Value = 0.2;

            % Create Label_4
            app.Label_4 = uilabel(app.ReverberationTab);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.Position = [14 241 81 22];
            app.Label_4.Text = 'Reverb_Delay';

            % Create Reverb_DelaySlider
            app.Reverb_DelaySlider = uislider(app.ReverberationTab);
            app.Reverb_DelaySlider.Limits = [0 1];
            app.Reverb_DelaySlider.Position = [116 250 256 3];
            app.Reverb_DelaySlider.Value = 0.2;

            % Create VoiceChangingTab
            app.VoiceChangingTab = uitab(app.TabGroup);
            app.VoiceChangingTab.Title = 'Voice Changing';

            % Create ProcessandAnalyseButton_5
            app.ProcessandAnalyseButton_5 = uibutton(app.VoiceChangingTab, 'push');
            app.ProcessandAnalyseButton_5.ButtonPushedFcn = createCallbackFcn(app, @ProcessandAnalyseButton_5Pushed, true);
            app.ProcessandAnalyseButton_5.Position = [415 15 127 24];
            app.ProcessandAnalyseButton_5.Text = 'Process and Analyse';

            % Create Label_12
            app.Label_12 = uilabel(app.VoiceChangingTab);
            app.Label_12.HorizontalAlignment = 'right';
            app.Label_12.Position = [172 255 196 22];
            app.Label_12.Text = 'Fundamental Frequency Coefficient';

            % Create FundamentalFrequencyCoefficientSlider
            app.FundamentalFrequencyCoefficientSlider = uislider(app.VoiceChangingTab);
            app.FundamentalFrequencyCoefficientSlider.Limits = [-1 1];
            app.FundamentalFrequencyCoefficientSlider.Position = [149 236 292 3];

            % Create SpeedModificationSliderLabel
            app.SpeedModificationSliderLabel = uilabel(app.VoiceChangingTab);
            app.SpeedModificationSliderLabel.HorizontalAlignment = 'right';
            app.SpeedModificationSliderLabel.Position = [217 150 107 22];
            app.SpeedModificationSliderLabel.Text = 'Speed Modification';

            % Create SpeedModificationSlider
            app.SpeedModificationSlider = uislider(app.VoiceChangingTab);
            app.SpeedModificationSlider.Limits = [0 3];
            app.SpeedModificationSlider.MajorTicks = [0 0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3];
            app.SpeedModificationSlider.MinorTicks = [0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2 2.05 2.1 2.15 2.2 2.25 2.3 2.35 2.4 2.45 2.5 2.55 2.6 2.65 2.7 2.75 2.8 2.85 2.9 2.95 3];
            app.SpeedModificationSlider.Position = [148 134 293 3];
            app.SpeedModificationSlider.Value = 1;

            % Create TheprocessedsequenceisusedasthenewinputButton
            app.TheprocessedsequenceisusedasthenewinputButton = uibutton(app.UIFigure, 'push');
            app.TheprocessedsequenceisusedasthenewinputButton.ButtonPushedFcn = createCallbackFcn(app, @TheprocessedsequenceisusedasthenewinputButtonPushed, true);
            app.TheprocessedsequenceisusedasthenewinputButton.Position = [309 126 288 24];
            app.TheprocessedsequenceisusedasthenewinputButton.Text = 'The processed sequence is used as the new input.';

            % Create SavetheprocessedsequenceButton
            app.SavetheprocessedsequenceButton = uibutton(app.UIFigure, 'push');
            app.SavetheprocessedsequenceButton.ButtonPushedFcn = createCallbackFcn(app, @SavetheprocessedsequenceButtonPushed, true);
            app.SavetheprocessedsequenceButton.Position = [417 80 180 24];
            app.SavetheprocessedsequenceButton.Text = 'Save the processed sequence.';

            % Create TakethefileasinputButton
            app.TakethefileasinputButton = uibutton(app.UIFigure, 'push');
            app.TakethefileasinputButton.ButtonPushedFcn = createCallbackFcn(app, @TakethefileasinputButtonPushed, true);
            app.TakethefileasinputButton.Position = [346 582 128 24];
            app.TakethefileasinputButton.Text = 'Take the file as input.';

            % Create PlayButton
            app.PlayButton = uibutton(app.UIFigure, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Position = [829 323 78 24];
            app.PlayButton.Text = 'Play';

            % Create PlayButton_2
            app.PlayButton_2 = uibutton(app.UIFigure, 'push');
            app.PlayButton_2.ButtonPushedFcn = createCallbackFcn(app, @PlayButton_2Pushed, true);
            app.PlayButton_2.Position = [828 41 78 24];
            app.PlayButton_2.Text = 'Play';

            % Create StopButton_2
            app.StopButton_2 = uibutton(app.UIFigure, 'push');
            app.StopButton_2.ButtonPushedFcn = createCallbackFcn(app, @StopButton_2Pushed, true);
            app.StopButton_2.Position = [928 323 78 24];
            app.StopButton_2.Text = 'Stop';

            % Create StopButton_3
            app.StopButton_3 = uibutton(app.UIFigure, 'push');
            app.StopButton_3.ButtonPushedFcn = createCallbackFcn(app, @StopButton_3Pushed, true);
            app.StopButton_3.Position = [927 41 78 24];
            app.StopButton_3.Text = 'Stop';

            % Create RecordingButton
            app.RecordingButton = uibutton(app.UIFigure, 'push');
            app.RecordingButton.ButtonPushedFcn = createCallbackFcn(app, @RecordingButtonPushed, true);
            app.RecordingButton.Position = [39 582 70 24];
            app.RecordingButton.Text = 'Recording';

            % Create StopButton
            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Position = [117 582 56 24];
            app.StopButton.Text = 'Stop';

            % Create Lamp
            app.Lamp = uilamp(app.UIFigure);
            app.Lamp.Position = [191 584 20 20];
            app.Lamp.Color = [0 0 0];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = main

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end