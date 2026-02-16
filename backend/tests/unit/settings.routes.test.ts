import express from 'express';
import settingsRoutes from '../../src/routes/settings.routes';
import { prisma } from '../../src/utils/prisma';

// Keep test setup dependency-free (no @types/supertest required).
// eslint-disable-next-line @typescript-eslint/no-var-requires
const request = require('supertest');

jest.mock('../../src/middleware/auth.middleware', () => ({
  authMiddleware: (req: express.Request, _res: express.Response, next: express.NextFunction) => {
    req.user = {
      id: 'user-1',
      firebaseUid: 'dev_user-1',
      email: 'dev_user-1@liftiq.dev',
    };
    next();
  },
}));

describe('settings routes', () => {
  const app = express();
  app.use(express.json());
  app.use('/settings', settingsRoutes);

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('GET /settings returns persisted unit + profile visibility', async () => {
    (prisma.user.findUnique as jest.Mock).mockResolvedValue({
      id: 'user-1',
      unitPreference: 'KG',
      socialProfile: { isPublic: true },
    });

    const res = await request(app).get('/settings');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.weightUnit).toBe('kg');
    expect(res.body.data.publicProfile).toBe(true);
  });

  it('PUT /settings persists supported fields', async () => {
    (prisma.user.update as jest.Mock).mockResolvedValue({ id: 'user-1' });
    (prisma.socialProfile.upsert as jest.Mock).mockResolvedValue({ isPublic: false });
    (prisma.user.findUnique as jest.Mock).mockResolvedValue({
      id: 'user-1',
      unitPreference: 'LBS',
      socialProfile: { isPublic: false },
    });

    const res = await request(app).put('/settings').send({
      weightUnit: 'lbs',
      publicProfile: false,
      theme: 'dark',
    });

    expect(res.status).toBe(200);
    expect(prisma.user.update).toHaveBeenCalled();
    expect(prisma.socialProfile.upsert).toHaveBeenCalled();
    expect(res.body.data.weightUnit).toBe('lbs');
    expect(res.body.data.publicProfile).toBe(false);
  });

  it('POST /settings/gdpr/delete records deletion request', async () => {
    const now = new Date('2026-02-16T00:00:00.000Z');
    (prisma.user.update as jest.Mock).mockResolvedValue({
      deletionRequested: now,
    });

    const res = await request(app).post('/settings/gdpr/delete');

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.status).toBe('pending');
    expect(res.body.data.requestedAt).toBe(now.toISOString());
  });
});
