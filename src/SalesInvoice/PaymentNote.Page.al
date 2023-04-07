page 50150 "TFB Payment Note"
{
    PageType = StandardDialog;
    Caption = 'Payment Note';
    Editable = true;
    ApplicationArea = All;


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
                    ToolTip = 'Specifies the customer name for which expected payment date is provided';
                }
                group(PhoneGroup)
                {
                    ShowCaption = false;
                    Visible = _ShowPhone or _ShowMobile;
                    field(Phone; _PhoneText)
                    {
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
                        ToolTip = 'Specifies explanation behind payment date of invoice';
                    }
                    group(ShowNotes)
                    {
                        ShowCaption = false;
                        Visible = not (_PreviousNoteDate = '');
                        field(PreviousNoteDate; _PreviousNoteDate)
                        {
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
                    ToolTip = 'Specifies the date at which the customer says payment will be taken';
                }
                field(CorrectDueDate; _CorrectDueDate)
                {
                    Editable = true;
                    ShowCaption = true;
                    Caption = 'Treat As Correction';
                    ToolTip = 'Specifies that the actual due date was incorrect and should be altered';

                }
            }
        }
    }

    actions
    {


    }


    procedure GetExpectedPaymentNote(): Text[512]

    begin
        exit(_ExpectedPaymentNote);
    end;

    procedure GetExpectedPaymentDate(): Date

    begin
        exit(_ExpectedPaymentDate);
    end;

    procedure GetIsCorrection(): Boolean

    begin
        exit(_CorrectDueDate);
    end;


    procedure SetupCustomerInfo(Customer: Record Customer; ExistingExpectedPaymentNote: Text[512]; ExistingExpectedPaymentDate: Date; LastDateTimeTaken: DateTime)
    var
        PreviousNote: TextBuilder;
    begin

        _Customer := Customer;
        _ExpectedPaymentDate := ExistingExpectedPaymentDate;


        if (LastDateTimeTaken > 0DT) then
            if (ExistingExpectedPaymentNote = '') then
                PreviousNote.AppendLine(StrSubstNo('Previous note from %1.', LastDateTimeTaken))
            else
                PreviousNote.AppendLine(StrSubstNo('%1 from %2', ExistingExpectedPaymentNote, LastDateTimeTaken));

        if _ExpectedPaymentDate > 0D then
            PreviousNote.AppendLine(StrSubstNo('Payment expected on %1', ExistingExpectedPaymentDate));

        _PreviousNoteDate := PreviousNote.ToText();

        _ShowPhone := Customer."Phone No." <> '';
        _ShowMobile := Customer."Mobile Phone No." <> '';

        if _ShowPhone then _PhoneText := 'Phone on ' + Customer."Phone No.";
        if _ShowPhone and _ShowMobile then _PhoneText += ' and mobile ' + Customer."Mobile Phone No.";
        if _ShowMobile then _PhoneText += 'Call mobile ' + Customer."Mobile Phone No.";



    end;


    procedure SetupVendorInfo(Vendor: Record Vendor; ExistingExpectedPaymentNote: Text[512]; ExistingExpectedPaymentDate: Date; LastDateTimeTaken: DateTime)
    var
        PreviousNote: TextBuilder;
    begin

        _Vendor := Vendor;
        _ExpectedPaymentDate := ExistingExpectedPaymentDate;


        if (LastDateTimeTaken > 0DT) then
            if (ExistingExpectedPaymentNote = '') then
                PreviousNote.AppendLine(StrSubstNo('Previous note from %1.', LastDateTimeTaken))
            else
                PreviousNote.AppendLine(StrSubstNo('%1 from %2', ExistingExpectedPaymentNote, LastDateTimeTaken));

        if _ExpectedPaymentDate > 0D then
            PreviousNote.AppendLine(StrSubstNo('Payment expected on %1', ExistingExpectedPaymentDate));

        _PreviousNoteDate := PreviousNote.ToText();

        _ShowPhone := Vendor."Phone No." <> '';
        _ShowMobile := Vendor."Mobile Phone No." <> '';

        if _ShowPhone then _PhoneText := 'Phone on ' + Vendor."Phone No.";
        if _ShowPhone and _ShowMobile then _PhoneText += ' and mobile ' + Vendor."Mobile Phone No.";
        if _ShowMobile then _PhoneText += 'Call mobile ' + Vendor."Mobile Phone No.";



    end;

    var
        _Customer: Record Customer;
        _Vendor: Record Vendor;
  
        _ExpectedPaymentNote: Text[512];
        _ExpectedPaymentDate: Date;

        _CorrectDueDate: Boolean;
        _PreviousNoteDate: Text;
        _ShowMobile: Boolean;
        _ShowPhone: Boolean;
        _PhoneText: Text;


}