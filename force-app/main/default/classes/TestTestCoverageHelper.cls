public with sharing class TestCoverageHelper {
    @IsTest
    private class TestCoverageHelper {
        @IsTest
        static void testDoNothing() {
            CoverageHelper.doNothing();
        }
    }

}