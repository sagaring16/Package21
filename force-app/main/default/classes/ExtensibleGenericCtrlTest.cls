@IsTest
private class ExtensibleGenericCtrlTest {

    // Stub subclass to track hook calls
    private class TestCtrl extends ExtensibleGenericCtrl {

        public Boolean setListParamCalled = false;

        public override void setListParam() {
            setListParamCalled = true;
        }

    }

    @IsTest
    static void testInit_NormalFlow() {
        Test.startTest();
        TestCtrl ctrl = new TestCtrl();
        String result = ctrl.init();
        Test.stopTest();

    }


} // CLOSES ExtensibleGenericCtrlTest class