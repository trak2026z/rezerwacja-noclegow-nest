// src/users/schemas/user.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import * as bcrypt from 'bcrypt';

// Definiujemy typ dokumentu bez metody comparePassword
export type UserBaseDocument = User & Document;

// Rozszerzamy typ o metodę comparePassword
export interface UserDocument extends UserBaseDocument {
  comparePassword(candidatePassword: string): Promise<boolean>;
}

@Schema({ timestamps: true })
export class User {
  // Usuwamy pole _id, ponieważ Document już je dostarcza
  
  @Prop({
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    match: /^\S+@\S+\.\S+$/,
  })
  email: string;

  @Prop({
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    minlength: 3,
    maxlength: 30,
    match: /^[a-zA-Z0-9]+$/,
  })
  username: string;

  @Prop({ required: true, minlength: 6 })
  password: string;
}

export const UserSchema = SchemaFactory.createForClass(User);

// Middleware do hashowania hasła przed zapisem
UserSchema.pre('save', async function (next) {
  // Używamy any, aby uniknąć problemów z typami
  const user = this as any;
  // Pomijamy hashowanie jeśli hasło nie zostało zmienione
  if (!user.isModified('password')) return next();
  try {
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(user.password, salt);
    next();
  } catch (err) {
    next(err);
  }
});

// Metoda do porównywania hasła
UserSchema.methods.comparePassword = function(candidatePassword: string): Promise<boolean> {
  return bcrypt.compare(candidatePassword, this.password);
};

// Konfiguracja transformacji do JSON (usuwanie hasła)
UserSchema.set('toJSON', {
  transform: (_doc, ret: any) => {
    delete ret.password;
    return ret;
  }
});
