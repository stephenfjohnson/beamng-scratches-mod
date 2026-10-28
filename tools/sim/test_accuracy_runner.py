"""The rendered test must fail on bleed, missing paint, drift or bake errors."""
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import test_accuracy as accuracy


class AccuracyChecks(unittest.TestCase):
    def setUp(self):
        self.noise = {'target': {'changed':0}, 'protected': {'changed':0}}
        self.checks = {'target': {'changed':100, 'fraction':0.001}, 'protected': {'changed':0}}
        self.stats = {'perf': {'bakeLayersTotal':1}, 'stamp': {'jobsFailed':0,'bakesFailed':0}}

    def passes(self):
        return accuracy.fixture_passes(self.noise,self.checks,self.stats)

    def test_visible_local_damage_passes(self):
        self.assertTrue(self.passes())

    def test_no_visible_damage_fails(self):
        self.checks['target']['changed'] = 0
        self.assertFalse(self.passes())

    def test_bleed_on_any_protected_view_fails(self):
        self.checks['inner_wall'] = {'changed':11}
        self.assertFalse(self.passes())

    def test_lighting_or_exposure_drift_fails(self):
        self.noise['target']['changed'] = 11
        self.assertFalse(self.passes())
        self.noise['target']['changed'] = 0
        self.checks['target']['fraction'] = 0.8
        self.assertFalse(self.passes())

    def test_failure_or_no_bake_fails(self):
        for field in ('jobsFailed','bakesFailed'):
            with self.subTest(field=field):
                self.stats['stamp'][field]=1
                self.assertFalse(self.passes())
                self.stats['stamp'][field]=0
        self.stats['perf']['bakeLayersTotal']=0
        self.assertFalse(self.passes())

    def test_native_render_errors_fail(self):
        errors=accuracy.relevant_errors(['10|E|dynamicDecals| draw skipped',
                                        '10|E|screenshot| unknown job id'])
        self.assertEqual(len(errors),1)
        self.assertFalse(accuracy.fixture_passes(self.noise,self.checks,self.stats,errors))

    def test_pixel_comparison_and_roi(self):
        import numpy as np
        from PIL import Image
        with tempfile.TemporaryDirectory() as folder:
            a,b,d = [Path(folder)/name for name in ('a.png','b.png','diff.png')]
            pixels=np.zeros((100,100,3),dtype=np.uint8)
            Image.fromarray(pixels).save(a)
            pixels[40:45,40:45] = 255
            pixels[0:10,0:10] = 255 # outside central ROI
            Image.fromarray(pixels).save(b)
            result=accuracy.difference(a,b,d)
            self.assertEqual(result['changed'],25)
            self.assertEqual(result['pixels'],3600)
            self.assertTrue(d.exists())
            Image.new('RGB',(10,10)).save(b)
            with self.assertRaisesRegex(RuntimeError,'resolution'):
                accuracy.difference(a,b,d)


if __name__=='__main__':
    unittest.main()
