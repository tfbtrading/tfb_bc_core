page 50150 "TFB Payment Note"
{
    PageType = StandardDialog;
    Caption = 'Payment Note';
    Editable = true;

    layout
    {
        area(Content)
        {
            group(Main)
            {
                ShowCaption = false;

                field(CustomerName; _Customer.Name)
                {
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                    ShowCaption = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name for which expected payment date is provided';
                }
                group(PhoneGroup)
                {
                    ShowCaption = false;
                    Visible = _ShowPhone or _ShowMobile;
                    field(Phone; _PhoneText)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Style = Subordinate;
                        StyleExpr = true;
                        ShowCaption = false;
                    }
                }


                group(Note)
                {
                    ShowCaption = false;
                    field(ExpectedPaymentNote; _ExpectedPaymentNote)
                    {
                        Editable = true;
                        MultiLine = true;
                        Caption = 'Notes';
                        ApplicationArea = All;
                        ToolTip = 'Specifies explanation behind payment date of invoice';
                    }
                    group(ShowNotes)
                    {
                        ShowCaption = false;
                        Visible = not (_PreviousNoteDate = '');
                        field(PreviousNoteDate; _PreviousNoteDate)
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = '';
                            Style = Subordinate;
                            MultiLine = true;
                            StyleExpr = true;
                        }
                    }

                }
                field(ExpectedPaymentDate; _ExpectedPaymentDate)
                {
                    Editable = true;
                    ShowCaption = true;
                    Caption = 'Expected Payment Date';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date at which the customer says payment will be taken';
                }
            }
        }
    }

    actions
    {


    }


    procedure GetExpectedPaymentNote(): Text[512]

    begin
        Exit(_ExpectedPaymentNote);
    end;

    procedure GetExpectedPaymentDate(): Date

    begin
        Exit(_ExpectedPaymentDate);
    end;


    procedure SetupCustomerInfo(Customer: Record Customer; ExpectedPaymentNote: Text[512]; ExpectedPaymentDate: Date; LastDateTimeTaken: DateTime)
    var
        PreviousNote: TextBuilder;
    begin

        _Customer := Customer;
        _ExpectedPaymentDate := ExpectedPaymentDate;


        If (LastDateTimeTaken > 0DT) then
            if (ExpectedPaymentNote = '') then
                PreviousNote.AppendLine(StrSubstNo('Previous note from %1.', LastDateTimeTaken))
            else
                PreviousNote.AppendLine(StrSubstNo('%1 from %2', ExpectedPaymentNote, LastDateTimeTaken));

        If _ExpectedPaymentDate > 0D then
            PreviousNote.AppendLine(StrSubstNo('Payment expected on %1', ExpectedPaymentDate));

        _PreviousNoteDate := PreviousNote.ToText();

        _ShowPhone := Customer."Phone No." <> '';
        _ShowMobile := Customer."Mobile Phone No." <> '';

        If _ShowPhone then _PhoneText := 'Phone on ' + Customer."Phone No.";
        If _ShowPhone and _ShowMobile then _PhoneText += ' and mobile ' + Customer."Mobile Phone No.";
        If _ShowMobile then _PhoneText += 'Call mobile ' + Customer."Mobile Phone No.";



    end;

    var
        _Customer: Record Customer;
        _CustomerName: Text;
        _ExpectedPaymentNote: Text[512];
        _ExpectedPaymentDate: Date;
        _PreviousNoteDate: Text;
        _ShowMobile: Boolean;
        _ShowPhone: Boolean;
        _PhoneText: Text;


}