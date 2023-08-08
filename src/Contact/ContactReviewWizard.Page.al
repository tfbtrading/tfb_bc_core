page 50174 "TFB Contact Review Wizard"
{
    Caption = 'Welcome to the Contact Review Wizard';
    PageType = NavigatePage;
    UsageCategory = None;
    ApplicationArea = All;


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
                                Editable = false;
                                MultiLine = true;
                                ToolTip = 'Specifies the last review that was entered for the contact';
                            }
                            field(_LastReviewDate; _LastReviewDate)
                            {
                                Caption = 'Last Completed On';
                                Editable = false;
                                ToolTip = 'Specifes the date the last review was completed on';
                            }
                        }

                        field(ReviewComment; _ReviewComment)
                        {
                            MultiLine = true;
                            Editable = true;
                            Caption = 'Review outcome';
                            ToolTip = 'Specifies in less than 256 characters summary of review outcome';

                            trigger OnValidate()

                            begin
                                if _ReviewComment = '' then
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

                field(UpdateContactStatus; _UpdateContactStatus)
                {
                    Editable = true;
                    Lookup = true;
                    LookupPageId = "TFB Contact Status List";
                    TableRelation = "TFB Contact Status".Status;
                    Caption = 'New Contact Status';
                    ToolTip = 'Specifies the new contact status';

                    trigger OnValidate()
                    var
                        ContactStatus: record "TFB Contact Status";

                    begin
                        ContactStatus.SetRange(Status, _UpdateContactStatus);
                        If ContactStatus.FindFirst() then
                            if ContactStatus.Stage = ContactStatus.Stage::Inactive then
                                _ShowDateSelection := false
                            else
                                _ShowDateSelection := true;


                    end;

                }
                group(dateselection)
                {
                    ShowCaption = false;
                    Visible = _ShowDateSelection;
                    field(PeriodicReviewSelection; _PeriodicReviewSelection)
                    {
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
                        Editable = true;
                        Caption = 'Next review date';
                        ToolTip = 'Specifies the date the next contact review should take place';

                        trigger OnValidate()

                        begin
                            if _NextReview < WorkDate() then
                                error('You must provide a date which is greater than todays date');
                        end;
                    }
                }
                field(NextStepConfirmation; getInstruction())
                {
                    ShowCaption = false;
                    MultiLine = true;
                    Editable = false;
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
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        TopBannerVisible: Boolean;
        _ExistingReview: Boolean;
        _IsFinished: Boolean;
        _UpdateContactStatus: Code[20];
        _LastReviewDate: Date;
        _NextReview: Date;
        _ShowDateSelection: Boolean;
        _PeriodicReviewSelection: Enum "TFB Periodic Review";
        Step: Option Start,Finish;
        _LastReviewComment: Text[256];

        _ReviewComment: Text[256];
        Instruction1Txt: Label '1) Update contact to say they are no longer in review';
        Instruction2Txt: Label '2) Add a relationship comment up to 256 characters';
        Instruction3Txt: Label '3) Set the next date of the review';
        Instruction4Txt: Label '4) Update the last review date with todays date';
        InstructionTxt: Label 'When you click finish we will:';




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

        _UpdateContactStatus := _contact."TFB Contact Status";

        if _contact."TFB Contact Stage" = _contact."TFB Contact Stage"::Inactive then
            _ShowDateSelection := false
        else
            _ShowDateSelection := true;

        if _LastReviewDate > 0D then begin
            _ExistingReview := true;
            _LastReviewComment := _contact."TFB Review Note";

        end
        else
            _ExistingReview := false;

        ResetNextReviewDate(_PeriodicReviewSelection);
    end;

    internal procedure GetReviewComment(): Text[256]
    begin
        exit(_ReviewComment);
    end;

    internal procedure GetNextPlannedDate(): Date
    begin
        exit(_NextReview);
    end;

    internal procedure GetContactStatus(): Code[20]
    begin
        exit(_UpdateContactStatus);
    end;


    local procedure FinishAction();
    var

    begin

        _IsFinished := true;
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


    procedure isFinished(): Boolean
    begin
        exit(_IsFinished);
    end;

    local procedure getInstruction(): Text[1000]

    var
        TypeHelper: CodeUnit "Type Helper";
        CRLF: text[2];
    begin

        CRLF := TypeHelper.CRLFSeparator();
        exit(InstructionTxt + CRLF + Instruction1Txt + CRLF + Instruction2Txt + CRLF + Instruction3Txt + CRLF + Instruction4Txt);
    end;

    local procedure ResetNextReviewDate(newPeriodicReviewSelection: Enum "TFB Periodic Review")

    var
        PeriodicDateFormula: DateFormula;
        IIndex: Integer;
        IValueName: Text;

    begin
        IIndex := newPeriodicReviewSelection.Ordinals().IndexOf(newPeriodicReviewSelection.AsInteger());
        newPeriodicReviewSelection.Names().Get(IIndex, IValueName);
        Evaluate(PeriodicDateFormula, IValueName);
        _NextReview := CalcDate(PeriodicDateFormula, WorkDate());
    end;



}