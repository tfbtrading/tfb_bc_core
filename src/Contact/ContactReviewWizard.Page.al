page 50174 "TFB Contact Review Wizard"
{
    Caption = 'Welcome to the Contact Review Wizard';
    PageType = NavigatePage;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = 'Provide details about the contact review';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = 'Nearly finished';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to the Contact Review Wizard")
                {
                    Caption = 'Get details on review';
                    ShowCaption = false;
                    Visible = Step1Visible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'First we will just confirm a few details';
                        group(LastReview)
                        {
                            Caption = 'Last review details';
                            Visible = _ExistingReview;
                            field(_LastReviewComment; _LastReviewComment)
                            {
                                Caption = 'Last Review';
                                ApplicationArea = All;
                                Editable = false;
                                MultiLine = true;
                            }
                            field(_LastReviewDate; _LastReviewDate)
                            {
                                Caption = 'Last Completed On';
                                ApplicationArea = All;
                                Editable = false;
                            }
                        }

                        field(ReviewComment; _ReviewComment)
                        {
                            ApplicationArea = All;
                            MultiLine = true;
                            Editable = true;
                            Caption = 'Review outcome';
                            ToolTip = 'Specifies in less than 80 characters summary of review outcome';

                            trigger OnValidate()

                            begin
                                If _ReviewComment = '' then
                                    error('You must provide a review outcome description');
                            end;
                        }

                    }
                }

            }

            group(Step2)
            {
                Caption = '';
                InstructionalText = 'Confirm next actions.';
                Visible = Step2Visible;
                //You might want to add fields here
                field(PeriodicReviewSelection; _PeriodicReviewSelection)
                {
                    ApplicationArea = All;
                    Editable = true;
                    Caption = 'Review period';
                    ToolTip = 'Helps set the next planned review date';

                    trigger OnValidate()

                    begin
                        ResetNextReviewDate(_PeriodicReviewSelection);
                    end;
                }
                field(NextReview; _NextReview)
                {
                    ApplicationArea = All;
                    Editable = true;
                    Caption = 'Next review date';
                    ToolTip = 'Specifies the date the next contact review should take place';

                    trigger OnValidate()

                    begin
                        if _NextReview < WorkDate() then
                            error('You must provide a date which is greater than todays date');
                    end;
                }

                field(NextStepConfirmation; getInstruction())
                {
                    ShowCaption = false;
                    MultiLine = true;
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Gives details of the next step';
                }
            }



        }
    }
    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Back action.';
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Next action.';
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Executes the Finish action.';
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    var


    begin

        Step := Step::Start;
        EnableControls();

    end;




    var

        InstructionTxt: Label 'When you click finish we will:';

        Instruction1Txt: Label '1) Update contact to say they are no longer in review';

        Instruction2Txt: Label '2) Add a relationship comment up to 80 characters';

        Instruction3Txt: Label '3) Set the next date of the review';

        Instruction4Txt: Label '4) Update the last review date with todays date';


        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";

        Step: Option Start,Finish;

        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;

        _ReviewComment: Text[256];
        _LastReviewComment: Text[256];

        _LastReviewDate: Date;
        _NextReview: Date;
        [InDataSet]
        _ExistingReview: Boolean;

        _PeriodicReviewSelection: Enum "TFB Periodic Review";
        _NextStepConfirmation: Text[1000];
        TopBannerVisible: Boolean;



    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep1();
            Step::Finish:
                ShowStep2();
        end;
    end;


    procedure InitFromContact(_contact: Record Contact)

    begin


        _PeriodicReviewSelection := _contact."TFB Default Review Period";

        _LastReviewDate := _contact."TFB Review Date Last Compl.";

        If _LastReviewDate > 0D then
            _ExistingReview := true
        else
            _ExistingReview := false;

        ResetNextReviewDate(_PeriodicReviewSelection);
    end;

    internal procedure GetReviewComment(): Text[80]
    begin
        Exit(_ReviewComment);
    end;

    internal procedure GetNextPlannedDate(): Date
    begin
        Exit(_NextReview);
    end;


    local procedure FinishAction();
    var

    begin


        CurrPage.Close();
    end;



    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowStep1();
    begin
        Step1Visible := true;

        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowStep2();
    begin
        Step2Visible := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;


    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        Step1Visible := false;
        Step2Visible := false;

    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
            MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
                MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
        then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;



    local procedure getInstruction(): Text[1000]

    var
        TypeHelper: CodeUnit "Type Helper";
        CRLF: text[2];
    begin

        CRLF := TypeHelper.CRLFSeparator();
        Exit(InstructionTxt + CRLF + Instruction1Txt + CRLF + Instruction2Txt + CRLF + Instruction3Txt + CRLF + Instruction4Txt);
    end;

    local procedure ResetNextReviewDate(_PeriodicReviewSelection: Enum "TFB Periodic Review")

    var
        PeriodicDateFormula: DateFormula;

        IValueName: Text;
        IIndex: Integer;
    begin
        IIndex := _PeriodicReviewSelection.Ordinals().IndexOf(_PeriodicReviewSelection.AsInteger());
        _PeriodicReviewSelection.Names().Get(IIndex, IValueName);
        Evaluate(PeriodicDateFormula, IValueName);
        _NextReview := CalcDate(PeriodicDateFormula, WorkDate());
    end;



}